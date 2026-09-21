import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, writeFileSync, readFileSync, existsSync, rmSync, symlinkSync } from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { test } from 'node:test';
import { Release, publicPackages, dependencyOrder, isPublished, manifestPath, releaseSubject, run } from './release.mjs';

const pkg = (name, version = '1.0.1') => ({ name, version, path: `packages/${name}`, tag: `${name}-v${version}` });
const response = (status, packageValue = pkg('a')) => ({ status, ok: status === 200, json: async () => ({ version: packageValue.version, pubspec: { name: packageValue.name } }) });

test('discovery excludes private packages and refuses public examples or escaping paths', () => {
  const packages = [{ ...pkg('a'), location: '/repo/packages/a', private: false }, { name: 'example', location: '/repo/packages/a/example', private: true }];
  assert.deepEqual(publicPackages(packages, '/repo'), [pkg('a')]);
  assert.throws(() => publicPackages([{ ...packages[1], private: false }], '/repo'), /outside/);
  assert.throws(() => publicPackages([{ ...packages[0], location: '/outside' }], '/repo'), /outside/);
});

test('topological order includes transitive dependencies and rejects cycles', () => {
  assert.deepEqual(dependencyOrder([pkg('c'), pkg('a'), pkg('b')], { c: ['b'], b: ['a'] }).map((p) => p.name), ['a', 'b', 'c']);
  assert.throws(() => dependencyOrder([pkg('a'), pkg('b')], { a: ['b'], b: ['a'] }), /cycle/);
});

test('discovery resolves symlinked checkout paths without allowing packages outside it', (t) => {
  const directory = mkdtempSync(path.join(os.tmpdir(), 'forge-release-paths-'));
  t.after(() => rmSync(directory, { recursive: true, force: true }));
  mkdirSync(path.join(directory, 'repo/packages/a'), { recursive: true });
  symlinkSync(path.join(directory, 'repo'), path.join(directory, 'alias'));
  assert.deepEqual(publicPackages([{ ...pkg('a'), private: false, location: path.join(directory, 'repo/packages/a') }], path.join(directory, 'alias')), [pkg('a')]);
});

test('pub.dev status distinguishes absence from authentication and service failures', async () => {
  assert.equal(await isPublished(pkg('a'), async () => response(404)), false);
  assert.equal(await isPublished(pkg('a'), async () => response(200)), true);
  await assert.rejects(isPublished(pkg('a'), async () => response(403)), /403/);
  let calls = 0;
  await assert.rejects(isPublished(pkg('a'), async () => { calls++; return response(503); }, async () => {}), /503/);
  assert.equal(calls, 4);
  await assert.rejects(isPublished(pkg('a'), async () => response(200, pkg('wrong'))), /Unexpected/);
});

test('pub.dev transient errors retry without incorrectly declaring a version unpublished', async () => {
  let calls = 0;
  assert.equal(await isPublished(pkg('a'), async () => { if (++calls < 3) throw new Error('network'); return response(200); }, async () => {}), true);
  assert.equal(calls, 3);
});

function fixture(t, packages = [pkg('a'), pkg('b')]) {
  const directory = mkdtempSync(path.join(os.tmpdir(), 'forge-release-test-'));
  t.after(() => rmSync(directory, { recursive: true, force: true }));
  const remote = path.join(directory, 'remote.git'), repo = path.join(directory, 'repo');
  run('git', ['init', '--bare', remote], directory, true);
  mkdirSync(repo);
  run('git', ['init', '-b', 'main'], repo, true);
  const git = (...args) => run('git', args, repo, true);
  git('config', 'user.name', 'Release Test');
  git('config', 'user.email', 'release-test@example.invalid');
  git('remote', 'add', 'origin', remote);
  mkdirSync(path.join(repo, '.github'));
  writeFileSync(path.join(repo, 'README.md'), 'fixture\n');
  writeFileSync(path.join(repo, '.gitignore'), 'pubspec_overrides.yaml\n');
  git('add', '.'); git('commit', '-m', 'feat: initial');
  git('push', '-u', 'origin', 'main');
  const base = git('rev-parse', 'HEAD');
  writeFileSync(path.join(repo, manifestPath), JSON.stringify({ schema: 1, base, packages }));
  git('add', '.'); git('commit', '-m', releaseSubject);
  const sha = git('rev-parse', 'HEAD'), commands = [];
  const release = new Release({ directory: repo, command: (command, args, cwd, capture) => {
    commands.push([command, ...args]);
    return run(command, args, cwd, command === 'git' || capture);
  } });
  return { repo, git, sha, commands, release };
}

test('push sends main first and one tag per request; repeated push is idempotent', async (t) => {
  const f = fixture(t);
  await f.release.push();
  const pushes = f.commands.filter((args) => args.includes('push'));
  assert.equal(pushes.length, 3);
  assert.equal(pushes[0].at(-1), 'HEAD:refs/heads/main');
  assert.equal(pushes[1].at(-1), `${f.sha}:refs/tags/a-v1.0.1`);
  assert.equal(pushes[2].at(-1), `${f.sha}:refs/tags/b-v1.0.1`);
  f.commands.length = 0;
  await f.release.push();
  assert.equal(f.commands.filter((args) => args.includes('push')).length, 1);
});

test('partial tag failure can resume using an older release after another merge', async (t) => {
  const f = fixture(t);
  f.git('push', 'origin', 'main');
  f.git('push', 'origin', `${f.sha}:refs/tags/a-v1.0.1`);
  writeFileSync(path.join(f.repo, 'README.md'), 'another merge\n');
  f.git('add', '.'); f.git('commit', '-m', 'fix: later merge'); f.git('push', 'origin', 'main');
  await f.release.pushTags(f.sha);
  assert.equal(f.commands.filter((args) => args.includes('push')).length, 1);
  assert.equal(f.release.remoteTag('b-v1.0.1'), f.sha);
});

test('conflicting remote tags are never overwritten', async (t) => {
  const f = fixture(t);
  f.git('push', 'origin', 'main');
  f.git('push', 'origin', `${f.git('rev-parse', 'HEAD^')}:refs/tags/a-v1.0.1`);
  await assert.rejects(f.release.pushTags(f.sha), /different commit/);
  assert.equal(f.commands.filter((args) => args.includes('push')).length, 0);
});

test('untracked files block releases and non-main prepare is refused', async (t) => {
  const f = fixture(t);
  writeFileSync(path.join(f.repo, 'secret.txt'), 'local data');
  await assert.rejects(f.release.push(), /clean worktree/);
  rmSync(path.join(f.repo, 'secret.txt'));
  f.git('switch', '-c', 'feature');
  await assert.rejects(f.release.prepare(), /main checkout/);
});

test('prepare reuses an already pushed release and does not bump again', async (t) => {
  const f = fixture(t);
  f.git('push', 'origin', 'main');
  await f.release.prepare();
  assert.equal(f.git('rev-parse', 'HEAD'), f.sha);
  assert.equal(f.commands.some((args) => args[0] === 'melos'), false);
});

test('prepare refuses to abandon a previous incomplete tag push', async (t) => {
  const f = fixture(t);
  f.git('push', 'origin', 'main');
  writeFileSync(path.join(f.repo, 'README.md'), 'later merge\n');
  f.git('add', '.'); f.git('commit', '-m', 'fix: later merge'); f.git('push', 'origin', 'main');
  await assert.rejects(f.release.prepare(), /Recover the previous release/);
});

test('manifest must belong to its release commit', (t) => {
  const f = fixture(t);
  assert.equal(f.release.manifest().base, f.git('rev-parse', 'HEAD^'));
  f.git('commit', '--allow-empty', '-m', 'fix: ordinary commit');
  assert.throws(() => f.release.manifest(), /not the release commit/);
});

function publishFixture(t, { published = async () => false, failTest = false, flutter = false } = {}) {
  const f = fixture(t, [pkg('a'), pkg('b')]);
  f.git('push', 'origin', 'main');
  mkdirSync(path.join(f.repo, 'packages/a'), { recursive: true });
  mkdirSync(path.join(f.repo, 'packages/b/test'), { recursive: true });
  mkdirSync(path.join(f.repo, 'packages/b/lib'), { recursive: true });
  mkdirSync(path.join(f.repo, 'packages/b/example'), { recursive: true });
  // Empty directories aren't tracked and therefore don't dirty the fixture.
  const commands = [];
  const release = new Release({ directory: f.repo, published, pause: async () => {}, command: (command, args, cwd, capture) => {
    commands.push([command, ...args]);
    if (command === 'git') return run(command, args, cwd, true);
    if (command === 'melos' && args.includes('--graph')) return JSON.stringify({ b: ['a'] });
    if (command === 'melos' && args.includes('--flutter')) return JSON.stringify(flutter ? [{ name: 'b' }] : []);
    if (command === 'melos') return JSON.stringify([pkg('a'), pkg('b')].map((p) => ({ ...p, private: false, location: path.join(f.repo, p.path) })));
    if (['dart', 'flutter'].includes(command) && args[0] === 'pub' && args[1] === 'get') assert.equal(readFileSync(path.join(cwd, 'pubspec_overrides.yaml'), 'utf8'), 'resolution:\n');
    if (failTest && args[0] === 'test') throw new Error('tests failed');
    return '';
  } });
  return { ...f, commands, release };
}

test('publish waits for dependencies, checks the package and dry-runs without upload', async (t) => {
  let attempts = 0;
  const f = publishFixture(t, { published: async (p) => p.name === 'a' && ++attempts >= 3 });
  await f.release.publish('b-v1.0.1');
  assert.equal(attempts, 3);
  assert.equal(existsSync(path.join(f.repo, 'packages/b/pubspec_overrides.yaml')), false);
  assert.ok(f.commands.some((args) => args.join(' ') === 'dart test'));
  assert.ok(f.commands.some((args) => args.join(' ') === 'dart pub publish --dry-run'));
  assert.equal(f.commands.some((args) => args.includes('--force') || args.includes('bootstrap')), false);
});

test('failed tests and dependency timeout prevent publication', async (t) => {
  const f = publishFixture(t, { published: async (p) => p.name === 'a', failTest: true });
  await assert.rejects(f.release.publish('b-v1.0.1'), /tests failed/);
  assert.equal(existsSync(path.join(f.repo, 'packages/b/pubspec_overrides.yaml')), false);
  assert.equal(f.commands.some((args) => args.includes('publish')), false);
  const timeout = publishFixture(t);
  await assert.rejects(timeout.release.publish('b-v1.0.1'), /Dependency a-v1.0.1 is unavailable/);
  assert.equal(timeout.commands.some((args) => args.includes('publish')), false);
});

test('standalone Flutter checks do not reenter example workspace resolution', async (t) => {
  const f = publishFixture(t, { published: async (p) => p.name === 'a', flutter: true });
  await f.release.publish('b-v1.0.1');
  const commands = f.commands.filter((args) => ['flutter', 'dart'].includes(args[0])).map((args) => args.join(' '));
  assert.deepEqual(commands, [
    'flutter pub get --no-example',
    'dart analyze --fatal-infos lib',
    'dart analyze --fatal-infos test',
    'flutter test --no-pub',
    'dart pub publish --dry-run',
  ]);
  assert.equal(existsSync(path.join(f.repo, 'packages/b/pubspec_overrides.yaml')), false);
});

test('already published package is skipped without resolving or publishing', async (t) => {
  const f = publishFixture(t, { published: async () => true });
  await f.release.publish('b-v1.0.1');
  assert.equal(f.commands.some((args) => args[0] === 'dart' || args[0] === 'flutter'), false);
});

test('wrong tags and uploads outside a tag-push workflow are refused', async (t) => {
  const f = publishFixture(t);
  await assert.rejects(f.release.publish('b-v2.0.0'), /does not match/);
  await assert.rejects(f.release.publish('b-v1.0.1', true), /tag-push run/);
});

test('real Melos prepares a changed package and its dependent in one commit', { skip: process.env.RELEASE_INTEGRATION !== '1' }, async (t) => {
  const f = fixture(t);
  rmSync(path.join(f.repo, manifestPath));
  writeFileSync(path.join(f.repo, '.gitignore'), '.dart_tool/\n.idea/\n*.iml\npubspec_overrides.yaml\n*.lock\n');
  writeFileSync(path.join(f.repo, 'pubspec.yaml'), 'name: release_fixture\npublish_to: none\nenvironment:\n  sdk: ">=3.12.0 <4.0.0"\ndev_dependencies:\n  melos: 8.8.0\nworkspace:\n  - packages/forge_fixture_a\n  - packages/forge_fixture_b\nmelos:\n  command:\n    version:\n      workspaceChangelog: false\n      fetchTags: false\n');
  for (const name of ['a', 'b']) {
    const directory = path.join(f.repo, `packages/forge_fixture_${name}`);
    mkdirSync(path.join(directory, 'lib'), { recursive: true });
    writeFileSync(path.join(directory, 'pubspec.yaml'), `name: forge_fixture_${name}\nversion: 0.0.1\nresolution: workspace\nenvironment:\n  sdk: ">=3.12.0 <4.0.0"\n${name === 'b' ? 'dependencies:\n  forge_fixture_a: ^0.0.1\n' : ''}`);
    writeFileSync(path.join(directory, 'CHANGELOG.md'), '## 0.0.1\nInitial version.\n');
    writeFileSync(path.join(directory, `lib/${name}.dart`), 'const value = 1;\n');
  }
  f.git('add', '.'); f.git('commit', '-m', 'feat: initial fixture packages');
  for (const name of ['a', 'b']) f.git('tag', `forge_fixture_${name}-v0.0.1`);
  f.git('push', 'origin', 'main', '--tags');
  writeFileSync(path.join(f.repo, 'packages/forge_fixture_a/lib/a.dart'), 'const value = 2;\n');
  f.git('add', '.'); f.git('commit', '-m', 'fix(forge_fixture_a): update value');
  f.git('push', 'origin', 'main');
  run('dart', ['pub', 'get'], f.repo, true);
  const base = f.git('rev-parse', 'HEAD');
  f.release.published = async () => false;
  await f.release.prepare();
  assert.equal(f.git('rev-parse', 'HEAD^'), base);
  assert.deepEqual(f.release.manifest().packages.map((p) => [p.name, p.version]), [['forge_fixture_a', '0.0.2'], ['forge_fixture_b', '0.0.2']]);
  assert.equal(f.git('status', '--porcelain'), '');
});
