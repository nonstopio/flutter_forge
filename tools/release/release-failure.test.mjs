import assert from 'node:assert/strict';
import { test } from 'node:test';
import { reportFailure, diagnostic } from '../../.github/scripts/release-failure.mjs';

function fixture({ existing = false, diagnosticsFail = false, conclusion = 'failure' } = {}) {
  const writes = [];
  const rest = {
    actions: { listJobsForWorkflowRunAttempt: 'jobs', downloadJobLogsForWorkflowRun: async () => ({ data: 'Error: package validation failed\nAuthorization: Bearer abc123\n' }) },
    checks: { listAnnotations: 'annotations' },
    issues: {
      listForRepo: 'issues',
      create: async (args) => { writes.push(args); return { data: { html_url: 'https://example.invalid/issue/1' } }; },
      update: async (args) => { writes.push(args); return { data: { html_url: 'https://example.invalid/issue/1' } }; },
    },
  };
  const github = { rest, paginate: async (method) => {
    if (method === 'issues') return existing ? [{ number: 1, body: '<!-- pub-release-run:42 -->' }] : [];
    if (diagnosticsFail) throw new Error('logs unavailable');
    if (method === 'jobs') return [{ id: 2, name: 'publish', conclusion: 'failure', html_url: 'https://example.invalid/job/2', check_run_url: 'https://example.invalid/check/3', steps: [{ number: 4, name: 'Validate and publish', conclusion: 'failure' }] }];
    return [{ annotation_level: 'failure', message: 'dart pub publish exited with 65' }];
  } };
  const context = { repo: { owner: 'nonstopio', repo: 'flutter_forge' }, payload: { workflow_run: { id: 42, run_attempt: 2, name: 'Publish to pub.dev', conclusion, head_sha: 'abc', head_branch: 'a-v1.0.1', html_url: 'https://example.invalid/run/42' } } };
  return { github, context, core: { warning() {}, notice() {} }, writes };
}

test('failure issue includes the failed step, diagnostics, commit and recovery link', async () => {
  const f = fixture();
  await reportFailure(f);
  assert.equal(f.writes.length, 1);
  assert.match(f.writes[0].body, /Validate and publish/);
  assert.match(f.writes[0].body, /exited with 65/);
  assert.match(f.writes[0].body, /package validation failed/);
  assert.match(f.writes[0].body, /RELEASING.md#recover-a-failed-release/);
  assert.doesNotMatch(f.writes[0].body, /abc123/);
});

test('retry updates the same issue and reopens it', async () => {
  const f = fixture({ existing: true });
  await reportFailure(f);
  assert.equal(f.writes[0].issue_number, 1);
  assert.equal(f.writes[0].state, 'open');
});

test('reporting still opens an issue if startup diagnostics are unavailable', async () => {
  const f = fixture({ diagnosticsFail: true, conclusion: 'timed_out' });
  await reportFailure(f);
  assert.equal(f.writes.length, 1);
  assert.match(f.writes[0].body, /did not return job details/);
});

test('success does not create a failure issue', async () => {
  const f = fixture({ conclusion: 'success' });
  await reportFailure(f);
  assert.equal(f.writes.length, 0);
});

test('diagnostics redact common credentials and prevent code fence escapes and mentions', () => {
  const text = diagnostic('ghp_secret github_pat_secret eyJabc.def.ghi https://user:password@host/ ``` @team');
  assert.doesNotMatch(text, /secret|password|eyJabc|```|@team/);
});
