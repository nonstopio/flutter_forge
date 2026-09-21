#!/usr/bin/env node
// Repository release CLI. Requires Node 22+ and the resolved Flutter workspace.
import { spawnSync } from 'node:child_process';
import { existsSync, realpathSync, writeFileSync, unlinkSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

export const manifestPath = '.github/release-manifest.json';
export const releaseSubject = 'chore(release): publish packages';
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

export function run(command, args, cwd = root, capture = false) {
  // Resolve the pinned workspace version, independent of global activation.
  if (command === 'melos') { command = 'dart'; args = ['run', 'melos', ...args]; }
  if (!capture) console.log(`> ${command} ${args.join(' ')}`);
  const result = spawnSync(command, args, {
    cwd, encoding: 'utf8', stdio: capture ? 'pipe' : 'inherit',
    env: { ...process.env, CI: 'true', MELOS_NO_UPDATE_CHECK: 'true' },
    maxBuffer: 20 * 1024 * 1024,
  });
  if (result.error) throw result.error;
  if (result.status !== 0) {
    throw new Error(`${command} ${args.join(' ')} failed (exit ${result.status}).\n${result.stderr || ''}`);
  }
  return result.stdout?.trim() || '';
}

export function publicPackages(packages, directory) {
  const canonical = (value) => existsSync(value) ? realpathSync(value) : value;
  return packages.filter((pkg) => !pkg.private).map((pkg) => {
    const relative = path.relative(canonical(directory), canonical(pkg.location)).split(path.sep).join('/');
    if (!/^(packages|plugins)\/[a-zA-Z0-9_]+$/.test(relative)) {
      throw new Error(`Public package ${pkg.name} is outside packages/* or plugins/*: ${relative}`);
    }
    if (!/^[a-z][a-z0-9_]*$/.test(pkg.name) || !/^\d+\.\d+\.\d+(?:-[\w.-]+)?(?:\+[\w.-]+)?$/.test(pkg.version)) {
      throw new Error(`Invalid package name/version: ${pkg.name} ${pkg.version}`);
    }
    return { name: pkg.name, version: pkg.version, path: relative, tag: `${pkg.name}-v${pkg.version}` };
  });
}

export function dependencyOrder(packages, graph) {
  const byName = new Map(packages.map((pkg) => [pkg.name, pkg]));
  const result = [], done = new Set(), visiting = new Set();
  function visit(pkg) {
    if (done.has(pkg.name)) return;
    if (visiting.has(pkg.name)) throw new Error(`Dependency cycle at ${pkg.name}`);
    visiting.add(pkg.name);
    for (const name of graph[pkg.name] || []) if (byName.has(name)) visit(byName.get(name));
    visiting.delete(pkg.name);
    done.add(pkg.name);
    result.push(pkg);
  }
  packages.forEach(visit);
  return result;
}

// A 404 alone means unpublished. Network errors must never look like absence.
export async function isPublished(pkg, request = fetch, pause = sleep) {
  const url = `https://pub.dev/api/packages/${pkg.name}/versions/${encodeURIComponent(pkg.version)}`;
  for (let attempt = 0; attempt < 4; attempt++) {
    try {
      const response = await request(url, { signal: AbortSignal.timeout(30_000) });
      if (response.status === 404) return false;
      if (response.ok) {
        const data = await response.json();
        if (data.version !== pkg.version || data.pubspec?.name !== pkg.name) throw new Error(`Unexpected pub.dev response for ${pkg.tag}`);
        return true;
      }
      if (response.status !== 429 && response.status < 500) throw new Error(`pub.dev returned HTTP ${response.status} for ${pkg.tag}`);
      if (attempt === 3) throw new Error(`pub.dev returned HTTP ${response.status} for ${pkg.tag}`);
    } catch (error) {
      if (attempt === 3 || error.message.startsWith('pub.dev returned HTTP') || error.message.startsWith('Unexpected pub.dev')) throw error;
    }
    await pause(1000 * 2 ** attempt);
  }
  throw new Error(`Cannot determine publication status of ${pkg.tag}`);
}

export class Release {
  constructor({ directory = root, command = run, published = isPublished, pause = sleep } = {}) {
    this.directory = directory;
    this.command = command;
    this.published = published;
    this.pause = pause;
  }
  exec(command, args, capture = false, directory = this.directory) {
    return this.command(command, args, directory, capture);
  }
  git(...args) { return this.exec('git', args, true); }
  packages() {
    return publicPackages(JSON.parse(this.exec('melos', ['list', '--json'], true)), this.directory);
  }
  graph() { return JSON.parse(this.exec('melos', ['list', '--graph'], true)); }
  clean() {
    if (this.git('status', '--porcelain')) throw new Error('Release requires a clean worktree, including untracked files.');
  }
  manifest(commit = 'HEAD') {
    const data = JSON.parse(this.git('show', `${commit}:${manifestPath}`));
    if (data.schema !== 1 || !Array.isArray(data.packages) || !/^[a-f0-9]{40}$/.test(data.base)) throw new Error('Invalid release manifest.');
    if (this.git('log', '-1', '--format=%s', commit) !== releaseSubject || this.git('rev-parse', `${commit}^`) !== data.base) {
      throw new Error(`${commit} is not the release commit described by its manifest.`);
    }
    return data;
  }
  remoteTag(tag) {
    const lines = this.git('ls-remote', '--tags', 'origin', `refs/tags/${tag}`, `refs/tags/${tag}^{}`).split('\n');
    return lines.find((line) => line.endsWith('^{}'))?.split('\t')[0] || lines.find((line) => line.endsWith(`refs/tags/${tag}`))?.split('\t')[0];
  }
  async prepare() {
    this.clean();
    if (this.git('branch', '--show-current') !== 'main') throw new Error('Prepare releases from a clean main checkout.');
    this.exec('git', ['fetch', 'origin', 'main', '--tags']);
    const base = this.git('rev-parse', 'HEAD');
    if (base !== this.git('rev-parse', 'origin/main')) throw new Error('main moved. Start again from origin/main; do not force push a release.');
    if (this.git('log', '-1', '--format=%s') === releaseSubject) {
      this.manifest();
      console.log('Reusing the existing release commit. Run push to retry missing tags.');
      return;
    }
    // Do not silently abandon tags if a previous push was interrupted.
    if (existsSync(path.join(this.directory, manifestPath))) {
      const previous = this.git('log', '-1', '--format=%H', '--', manifestPath);
      for (const pkg of this.manifest(previous).packages) {
        if (this.remoteTag(pkg.tag) !== previous) throw new Error(`Recover the previous release first: node tools/release/release.mjs push-tags ${previous}`);
      }
    }
    const before = this.packages();
    this.exec('melos', ['version', '--yes', '--no-git-commit-version', ...before.map((pkg) => `--scope=${pkg.name}`)]);
    const after = this.packages();
    const changed = after.filter((pkg) => before.find((old) => old.name === pkg.name)?.version !== pkg.version);
    if (!changed.length) {
      this.clean();
      console.log('No versionable changes. Nothing to release.');
      return;
    }
    const graph = this.graph();
    const packages = dependencyOrder(changed, graph);
    // Hooks must not change another public package without versioning it.
    for (const pkg of after.filter((pkg) => !changed.some((item) => item.name === pkg.name))) {
      if (this.git('diff', 'HEAD', '--', pkg.path)) throw new Error(`Version hook changed unversioned package ${pkg.name}. Include that change in a versionable commit first.`);
    }
    for (const pkg of packages) {
      if (await this.published(pkg)) throw new Error(`${pkg.tag} already exists on pub.dev. Reconcile main and release tags before versioning.`);
    }
    this.exec('melos', ['bootstrap', ...packages.map((pkg) => `--scope=${pkg.name}`), '--include-dependencies']);
    for (const pkg of packages) this.validate(pkg);
    if (this.git('rev-parse', 'HEAD') !== base) throw new Error('A version hook created a commit. Hooks must only stage files.');
    writeFileSync(path.join(this.directory, manifestPath), `${JSON.stringify({ schema: 1, base, packages }, null, 2)}\n`);
    // Stage only tracked version/hook edits and the new manifest. Unexpected
    // output from a test must not be silently included in a release.
    this.exec('git', ['add', '--update']);
    this.exec('git', ['add', manifestPath]);
    if (this.git('ls-files', '--others', '--exclude-standard')) throw new Error('Release checks created untracked files; inspect them before preparing again.');
    this.exec('git', ['commit', '-m', `${releaseSubject}\n\n${packages.map((pkg) => ` - ${pkg.tag}`).join('\n')}`]);
    console.log(`Prepared ${packages.length} package(s). Review the commit, then run push.`);
  }
  validate(pkg, flutter) {
    const directory = path.join(this.directory, pkg.path);
    flutter ??= JSON.parse(this.exec('melos', ['list', '--flutter', '--json'], true)).some((item) => item.name === pkg.name);
    this.exec('dart', ['analyze', '--fatal-infos'], false, directory);
    if (existsSync(path.join(directory, 'test'))) this.exec(flutter ? 'flutter' : 'dart', ['test'], false, directory);
  }
  async push() {
    this.clean();
    if (this.git('branch', '--show-current') !== 'main') throw new Error('Push releases from main.');
    if (this.git('log', '-1', '--format=%s') !== releaseSubject) {
      console.log('No prepared release to push.');
      return;
    }
    this.manifest();
    // A normal fast-forward push fails safely if another merge won the race.
    this.exec('git', ['-c', 'push.followTags=false', 'push', 'origin', 'HEAD:refs/heads/main']);
    await this.pushTags(this.git('rev-parse', 'HEAD'));
  }
  async pushTags(commit) {
    this.clean();
    if (!/^[a-f0-9]{40}$/.test(commit)) throw new Error('push-tags requires a full release commit SHA.');
    this.exec('git', ['fetch', 'origin', 'main']);
    this.git('merge-base', '--is-ancestor', commit, 'origin/main');
    const manifest = this.manifest(commit);
    for (const pkg of manifest.packages) {
      if (!/^[a-z][a-z0-9_]*-v\d+\.\d+\.\d+(?:-[\w.-]+)?(?:\+[\w.-]+)?$/.test(pkg.tag)) throw new Error(`Invalid release tag ${pkg.tag}`);
      const remote = this.remoteTag(pkg.tag);
      if (remote && remote !== commit) throw new Error(`${pkg.tag} already points to a different commit. Never move a release tag.`);
      if (remote) continue;
      // Push one ref per request: GitHub suppresses push events for >3 tags.
      // Direct refspecs also avoid accidentally pushing unrelated local tags.
      this.exec('git', ['-c', 'push.followTags=false', 'push', 'origin', `${commit}:refs/tags/${pkg.tag}`]);
    }
  }
  async publish(tag, execute = false) {
    this.clean();
    if (process.env.PUB_HOSTED_URL && process.env.PUB_HOSTED_URL !== 'https://pub.dev') throw new Error('Release publishing requires PUB_HOSTED_URL=https://pub.dev.');
    const packages = this.packages();
    const pkg = packages.find((item) => item.tag === tag);
    if (!pkg) throw new Error(`Tag ${tag} does not match a public package version in this checkout.`);
    if (execute && (process.env.GITHUB_ACTIONS !== 'true' || process.env.GITHUB_EVENT_NAME !== 'push' || process.env.GITHUB_REF !== `refs/tags/${tag}`)) {
      throw new Error('Uploads require a GitHub Actions tag-push run. For first publication use dart pub publish interactively.');
    }
    const manifest = this.manifest();
    if (!manifest.packages.some((item) => item.tag === pkg.tag && item.path === pkg.path && item.name === pkg.name && item.version === pkg.version)) throw new Error(`${tag} is absent from this release manifest.`);
    this.exec('git', ['fetch', 'origin', 'main']);
    this.git('merge-base', '--is-ancestor', 'HEAD', 'origin/main');
    if (await this.published(pkg)) {
      console.log(`${pkg.tag} is already published; retry is a no-op.`);
      return;
    }
    // Separate tag jobs may start in any order. Await the exact dependency
    // versions from this commit before resolving against the public registry.
    const graph = this.graph();
    for (const name of graph[pkg.name] || []) {
      const dependency = packages.find((item) => item.name === name);
      if (!dependency) throw new Error(`${pkg.name} depends on private workspace package ${name}.`);
      let available = false;
      for (let attempt = 0; attempt < 60; attempt++) {
        if (await this.published(dependency)) { available = true; break; }
        console.log(`Waiting for ${dependency.tag} on pub.dev (${attempt + 1}/60)…`);
        await this.pause(10_000);
      }
      if (!available) throw new Error(`Dependency ${dependency.tag} is unavailable after 10 minutes. Resolve its publish failure, then rerun this tag workflow.`);
    }
    const directory = path.join(this.directory, pkg.path);
    const override = path.join(directory, 'pubspec_overrides.yaml');
    if (existsSync(override)) throw new Error('Publish from a fresh checkout without pubspec_overrides.yaml.');
    const flutter = JSON.parse(this.exec('melos', ['list', '--flutter', '--json'], true)).some((item) => item.name === pkg.name);
    // Dart's documented opt-out from workspace resolution. No dependency
    // overrides: get/analyze/test/publish must resolve this package on pub.dev.
    // pub excludes this file from the uploaded archive; the source stays intact.
    writeFileSync(override, 'resolution:\n', { flag: 'wx' });
    try {
      this.exec(flutter ? 'flutter' : 'dart', ['pub', 'get'], false, directory);
      this.validate(pkg, flutter);
      this.exec('dart', ['pub', 'publish', '--dry-run'], false, directory);
      this.clean();
      if (execute) this.exec('dart', ['pub', 'publish', '--force'], false, directory);
      else console.log('Dry run passed. Upload is only enabled by --execute in the tag workflow.');
    } finally {
      unlinkSync(override);
    }
  }
}

export async function main(args) {
  const release = new Release();
  const [command, value, flag, ...extra] = args;
  if (extra.length) throw new Error('Too many arguments. Use --help.');
  switch (command) {
    case 'list':
      if (value) throw new Error('list takes no arguments.');
      console.log(JSON.stringify(release.packages(), null, 2)); break;
    case 'auth':
      if (value) throw new Error('auth takes no arguments.');
      console.log('Configure each package on pub.dev for repository nonstopio/flutter_forge, environment pub.dev, and these tag patterns:');
      for (const pkg of release.packages()) console.log(`${pkg.name}: ${pkg.name}-v{{version}} — https://pub.dev/packages/${pkg.name}/admin`);
      console.log('GitHub Actions obtains short-lived OIDC credentials with dart-lang/setup-dart. No pub.dev secret is required. See docs/RELEASING.md.'); break;
    case 'prepare':
    case 'push':
      if (value) throw new Error(`${command} takes no arguments.`);
      await release[command](); break;
    case 'push-tags':
      if (!value || flag) throw new Error('Usage: push-tags <full-release-commit-sha>');
      await release.pushTags(value); break;
    case 'publish':
      if (!value || (flag && flag !== '--execute')) throw new Error('Usage: publish <package-vVERSION> [--execute]');
      await release.publish(value, flag === '--execute'); break;
    case undefined:
    case '--help':
      console.log('Usage: node tools/release/release.mjs <command>\n\nlist                List public packages and current tags\nauth                Print pub.dev setup links and tag patterns\nprepare             Version changed packages with Melos, test, commit (main only)\npush                Push prepared main commit and each package tag\npush-tags <sha>     Resume interrupted tag pushes for a release on origin/main\npublish <tag>       Validate tagged release and dry-run publishing\npublish <tag> --execute   Upload from a GitHub Actions tag-push run\n\nSetup and recovery: docs/RELEASING.md'); break;
    default: throw new Error(`Unknown command: ${command}. Use --help.`);
  }
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  main(process.argv.slice(2)).catch((error) => { console.error(`Release failed: ${error.message}`); process.exitCode = 1; });
}
