const failures = new Set(['failure', 'timed_out', 'cancelled', 'action_required', 'startup_failure']);

export function diagnostic(text) {
  return String(text)
    .replace(/\x1b\[[0-9;]*m/g, '')
    .replace(/(?:gh[pousr]_[A-Za-z0-9_]+|github_pat_[A-Za-z0-9_]+|eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+)/g, '[REDACTED]')
    .replace(/(authorization\s*[:=]\s*(?:bearer|basic)\s+)\S+/gi, '$1[REDACTED]')
    .replace(/(https?:\/\/)[^\s/@]+:[^\s/@]+@/g, '$1[REDACTED]@')
    .replace(/`/g, "'")
    .replace(/@/g, '@\u200b')
    .slice(-7000);
}

export async function reportFailure({ github, context, core }) {
  const run = context.payload.workflow_run;
  if (!failures.has(run.conclusion)) return;
  const repo = context.repo;
  const marker = `<!-- pub-release-run:${run.id} -->`;
  const body = [marker, `## ${run.name} failed`, '',
    `- Run: [${run.id}, attempt ${run.run_attempt}](${run.html_url})`,
    `- Commit: \`${run.head_sha}\``, `- Ref: \`${diagnostic(run.head_branch)}\``,
    `- Result: **${run.conclusion}**`, '', '### Failure details', ''];
  try {
    const jobs = await github.paginate(github.rest.actions.listJobsForWorkflowRunAttempt, {
      ...repo, run_id: run.id, attempt_number: run.run_attempt, per_page: 100,
    });
    const failed = jobs.filter((job) => failures.has(job.conclusion));
    if (!failed.length) body.push('No failed job details are available. The run may have failed during startup; see the run link for GitHub’s diagnostic.');
    for (const job of failed) {
      body.push(`#### [${diagnostic(job.name)}](${job.html_url}) — ${job.conclusion}`);
      for (const step of job.steps || []) if (failures.has(step.conclusion)) body.push(`- Step ${step.number}: **${diagnostic(step.name)}** (${step.conclusion})`);
      try {
        const checkId = Number(job.check_run_url?.split('/').at(-1));
        if (checkId) {
          const annotations = await github.paginate(github.rest.checks.listAnnotations, { ...repo, check_run_id: checkId, per_page: 100 });
          for (const annotation of annotations.filter((item) => item.annotation_level === 'failure').slice(0, 5)) {
            body.push(`\n\`\`\`text\n${diagnostic(annotation.message)}\n\`\`\``);
          }
        }
        const logs = await github.rest.actions.downloadJobLogsForWorkflowRun({ ...repo, job_id: job.id });
        const text = typeof logs.data === 'string' ? logs.data : Buffer.from(logs.data).toString('utf8');
        body.push(`\n<details><summary>Job log tail (GitHub-masked)</summary>\n\n\`\`\`text\n${diagnostic(text.split('\n').slice(-45).join('\n'))}\n\`\`\`\n</details>`);
      } catch (error) {
        core.warning(`Could not retrieve some diagnostics for job ${job.id}: ${error.message}`);
        body.push('Some annotations/logs were unavailable. Open the job link above for the full error.');
      }
    }
  } catch (error) {
    core.warning(`Could not list failed jobs: ${error.message}`);
    body.push('GitHub did not return job details. Open the run link above to inspect its startup or runner error.');
  }
  // Leave room under GitHub's issue body limit even for many failed jobs.
  const details = body.join('\n').slice(0, 55_000);
  const finalBody = `${details}\n\n### Recovery\n\nFix the reported cause, then follow [release recovery](https://github.com/${repo.owner}/${repo.repo}/blob/main/docs/RELEASING.md#recover-a-failed-release). Already published versions are skipped on retry. Never move a published tag or reuse a version.\n`;
  const issues = await github.paginate(github.rest.issues.listForRepo, { ...repo, state: 'all', creator: 'github-actions[bot]', per_page: 100 });
  const existing = issues.find((issue) => !issue.pull_request && issue.body?.includes(marker));
  const fields = { ...repo, title: `[release] ${run.name} failed (run ${run.id})`, body: finalBody };
  const result = existing
    ? await github.rest.issues.update({ ...fields, issue_number: existing.number, state: 'open' })
    : await github.rest.issues.create(fields);
  core.notice(`Release failure issue: ${result.data.html_url}`);
}
