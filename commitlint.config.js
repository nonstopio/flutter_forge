export default {
  extends: ['@commitlint/config-conventional'],
  // Dependabot bodies carry long release-note URLs that break body-max-line-length.
  ignores: [(message) => message.includes('Signed-off-by: dependabot[bot]')],
};
