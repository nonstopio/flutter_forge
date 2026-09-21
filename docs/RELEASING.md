# Automated pub.dev releases

Merging into `main` starts **Prepare pub.dev release**. Melos 6.3.3 determines
version changes from Conventional Commits, updates affected dependents and
changelogs, and runs the existing NonStop CLI generation hooks. The release CLI
analyzes and tests the selected packages, creates one release commit, pushes it
to `main`, then pushes each package tag separately. Unchanged packages, examples,
brick hooks and other private packages are not published.

Each tag starts **Publish to pub.dev**. It checks the tag against the package
version and committed release manifest, waits for workspace dependencies to be
available on pub.dev, resolves public dependencies without Melos overrides,
runs analysis/tests and `dart pub publish --dry-run`, then uploads. Versions
already on pub.dev are skipped, so rerunning a partially completed release is safe.

The independent **Report release failure** workflow creates or updates one issue
per failed run with the commit, failed job/step, available annotations, a bounded
log excerpt, and recovery links. It also handles timeouts and cancellations.
Reporting itself requires working GitHub Actions/API access and enabled Issues;
an outage, disabled Actions, or revoked issue permissions cannot be reported by
the same unavailable service. Check the reporter workflow if no issue appears.

## One-time authentication setup

There are two separate identities: a GitHub App pushes commits/tags, and GitHub
OIDC authenticates each tag job to pub.dev. **No pub.dev password, refresh token,
or `credentials.json` is stored in GitHub.**

### 1. Check package ownership and first publication

Sign in to pub.dev as an uploader, or an administrator of the package's verified
publisher. All current public packages already exist on pub.dev. For any new
package, publish its first version interactively before enabling automation:

```sh
cd packages/your_package
flutter pub get
dart pub publish --dry-run
dart pub publish
```

Follow the Google sign-in prompt. That login is for the local first publication;
do not copy its credentials into CI. Keep the initial package version/tag aligned
with the repository before merging subsequent changes.

### 2. Create the GitHub publishing environment

In `nonstopio/flutter_forge`, open **Settings → Environments → New environment**
and create **`pub.dev`**. Allow deployment tags matching `*-v*` (choose selected
branches and tags and add a **tag** rule). The job declares `environment: pub.dev`.
Leave required reviewers disabled for fully automatic publishing; adding a
reviewer intentionally introduces an approval step for every publication.

### 3. Enable pub.dev automated publishing for every public package

Open each package's **Admin → Automated publishing → Enable publishing from
GitHub Actions**, and enter:

- Repository: **`nonstopio/flutter_forge`**
- Tag pattern: the exact value below, including literal `{{version}}`
- Require GitHub Actions environment: **`pub.dev`**
- If the UI offers event choices, enable **push** events.

| Package / admin settings | Tag pattern |
| --- | --- |
| [cli_core](https://pub.dev/packages/cli_core/admin) | `cli_core-v{{version}}` |
| [connectivity_wrapper](https://pub.dev/packages/connectivity_wrapper/admin) | `connectivity_wrapper-v{{version}}` |
| [contact_permission](https://pub.dev/packages/contact_permission/admin) | `contact_permission-v{{version}}` |
| [dzod](https://pub.dev/packages/dzod/admin) | `dzod-v{{version}}` |
| [html_rich_text](https://pub.dev/packages/html_rich_text/admin) | `html_rich_text-v{{version}}` |
| [morse_tap](https://pub.dev/packages/morse_tap/admin) | `morse_tap-v{{version}}` |
| [nonstop_cli](https://pub.dev/packages/nonstop_cli/admin) | `nonstop_cli-v{{version}}` |
| [ns_firebase_utils](https://pub.dev/packages/ns_firebase_utils/admin) | `ns_firebase_utils-v{{version}}` |
| [ns_intl_phone_input](https://pub.dev/packages/ns_intl_phone_input/admin) | `ns_intl_phone_input-v{{version}}` |
| [ns_utils](https://pub.dev/packages/ns_utils/admin) | `ns_utils-v{{version}}` |
| [timer_button](https://pub.dev/packages/timer_button/admin) | `timer_button-v{{version}}` |

To generate the current inventory locally:

```sh
dart pub get
dart pub global activate melos 6.3.3
node tools/release/release.mjs auth
```

`auth` prints configuration instructions; it never collects or stores credentials.
During a tag job, `id-token: write` permits `dart-lang/setup-dart` to obtain and
configure a short-lived OIDC token. Pub.dev checks the repository, tag/version,
and environment. `dart pub publish` automatically uses that credential. A branch
push cannot directly authenticate this publishing flow. See [Dart's automated
publishing guide](https://dart.dev/tools/pub/automated-publishing).

### 4. Create and install a GitHub release App

In your organization settings, open **Developer settings → GitHub Apps → New
GitHub App**. Create an organization-owned App, for example `Flutter Forge Releases`:

1. Use the repository URL as its homepage. Disable webhooks; this App only needs
   an installation token generated by Actions.
2. Set repository **Contents: Read and write**. Metadata read access is implicit;
   no organization permissions are needed.
3. Install it on **only `nonstopio/flutter_forge`**.
4. Copy the **App ID**, then generate and download a private key.
5. Under the repository's **Settings → Secrets and variables → Actions**, add
   repository variable **`RELEASE_APP_ID`** and repository secret
   **`RELEASE_APP_PRIVATE_KEY`** (the entire PEM file, including header/footer).

The equivalent GitHub CLI setup, after creating/installing the App, is:

```sh
gh variable set RELEASE_APP_ID --repo nonstopio/flutter_forge --body 'YOUR_APP_ID'
gh secret set RELEASE_APP_PRIVATE_KEY --repo nonstopio/flutter_forge < /secure/path/release-app.pem
```

The prepare workflow uses `actions/create-github-app-token` to get a temporary
installation token and passes it to checkout for authenticated Git pushes.
Do not replace this with `GITHUB_TOKEN`: GitHub suppresses new push-triggered
workflow runs for that token. [GitHub documents this restriction and the App
alternative](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow).

### 5. Configure repository rules and Actions

- Keep Issues enabled. The reporter requests `issues: write`, `actions: read`
  and `checks: read` using its own `GITHUB_TOKEN`; it does not use the release App.
- If organization policy restricts Actions or token permissions, allow the
  actions referenced in the four release workflow files and those permissions.
- Allow the release App to push version commits to `main`. If `main` requires
  pull requests/checks, add this App as a bypass actor on the applicable ruleset.
  A rule requiring a PR for *every* change cannot also allow direct automatic
  version commits without such an exception. Keep normal contributor PR rules.
- Protect package tags matching `*-v*` against unauthorized creation, updates,
  and deletion; allow the release App to create them. Never force-update a
  published tag. Pub.dev versions are immutable.
- Use squash merging with a Conventional Commit PR title, or preserve
  Conventional Commit messages in the merge. `fix(package): ...` produces patch
  releases, `feat(package): ...` minor releases, and breaking-change notation
  drives major changes according to Melos's version rules. A package with only
  non-versionable changes may produce no release. Dependents are updated by Melos.

### 6. Enable and verify the first release

Finish the preceding configuration before merging these workflow files. Merge
to `main` and inspect **Actions → Prepare pub.dev release**. Existing versionable
commits since the last package tags may be included in this first release.
Confirm its generated version commit, package tag runs, and pub.dev versions.
The version commit itself is excluded from recursive preparation.

The new release checks use Flutter **3.44.0**, matching the existing NonStop
template workflow. Packages on `origin/main` may have pre-existing SDK/dependency
or analyzer failures (for example, `contact_permission` still declares Dart
`<3.0.0`). Such packages need their compatibility fixes merged before they can
pass this pipeline. The separate dependency/coverage PR is not included here.

## CLI usage

Run from a checkout with Node 22+, Flutter 3.44.0 and Melos 6.3.3 on `PATH`:

```sh
node tools/release/release.mjs --help
node tools/release/release.mjs list
node --test tools/release/*.test.mjs
# Also exercise real Melos versioning and dependency updates in a temporary repo:
RELEASE_INTEGRATION=1 node --test tools/release/*.test.mjs
```

`prepare` operates only on a clean `main` exactly matching `origin/main`. It
changes versions/changelogs, runs hooks and validation, and creates a local
commit containing `.github/release-manifest.json`. It does not upload packages.
`push` pushes that commit normally (never with force) and one tag per request.
GitHub may omit push events when more than three tags are pushed together, so
do not replace the individual pushes with `git push --tags`/`--follow-tags`.

For a local preparation/review, use a separate clean clone on `main`, configure
your Git author, install root dependencies, and run:

```sh
node tools/release/release.mjs prepare
git show --stat
# Only when ready to start publishing using your authenticated Git remote:
node tools/release/release.mjs push
```

For a publication dry run, check out the prepared release commit in a fresh
checkout and use its package tag:

```sh
node tools/release/release.mjs publish nonstop_cli-v0.0.9
```

Replace the example tag with an actual prepared version. Uploading additionally
requires `--execute` and a matching GitHub Actions tag-push context. Do not run
Melos bootstrap in a publishing checkout: local dependency overrides would hide
missing published dependencies.

## Recover a failed release

Read the automatically created issue first. Its run/job links are authoritative
if the bounded log tail lacks the first error. Failure issues are updated on
failed retries; close them after verifying recovery.

- **Preparation failed before pushing:** fix the reported checks/configuration
  and merge the fix, or run **Prepare pub.dev release → Run workflow** on `main`.
  Preparation always starts at current `main`, including queued merges. A
  failed local preparation can leave version edits for inspection; retry from
  a fresh checkout instead of discarding unrelated work.
- **`main` advanced while preparing:** the normal push is rejected. Rerun the
  prepare workflow, which recomputes the release against current `main`.
- **Version commit was pushed but some tags were not:** rerun the preparation
  workflow while that commit remains `main`; it reuses the commit without a
  second version bump. If a later merge has landed, fetch the release SHA and
  recover missing tags from a clean checkout with authenticated Git access:

  ```sh
  git fetch origin main --tags
  node tools/release/release.mjs push-tags FULL_40_CHARACTER_RELEASE_SHA
  ```

  This verifies that the release is on `origin/main`, preserves existing tags,
  and creates only missing tags. Then rerun preparation for the later merge.
- **Publication or OIDC configuration failed:** fix pub.dev/App/environment
  settings, then use **Re-run failed jobs** on the original tag-triggered run.
  Do not delete/recreate tags, and do not use a branch workflow dispatch to
  publish. Successful packages are skipped when their versions already exist.
- **A dependency is not yet on pub.dev:** each dependent waits up to ten minutes
  for the exact version in the release commit. Fix/retry the dependency's tag
  run first, then rerun the dependent's job.
- **The tagged package needs a source fix:** merge a conventional fix commit to
  obtain a new Melos version and tag. Never mutate a previously published version.

Adding a package requires first publication and the same admin/tag/environment
setup. Discovery is automatic for public `packages/*` and `plugins/*` packages;
an accidentally public nested example/tool fails discovery rather than being
uploaded.
