# Versioning & releases

Edadat (`flutter_settings_framework`) uses **[SemVer](https://semver.org/)**:

| Part | When to bump |
|------|----------------|
| **MAJOR** | Breaking API changes |
| **MINOR** | Backward-compatible features |
| **PATCH** | Backward-compatible fixes |

**Milestone exception:** `0.6.0` is a packaging milestone (MPL-2.0 relicense, branding, first pub.dev publish) without a public API feature bump. Future docs-only work should prefer PATCH.

## Tag format

Git tags are `vMAJOR.MINOR.PATCH` (example: `v0.7.2`).

The tag **must** match `version:` in [`pubspec.yaml`](pubspec.yaml) (build metadata `+N` is ignored for tagging).

## Consumer apps

Prefer **pub.dev**:

```yaml
dependencies:
  flutter_settings_framework: ^0.7.2
```

Or pin a **git tag** (not `main` or a raw commit):

```yaml
dependencies:
  flutter_settings_framework:
    git:
      url: https://github.com/Zyzto/edadat.git
      ref: v0.7.2
```

## Release checklist

1. Update `version:` in `pubspec.yaml`.
2. Add a `## [X.Y.Z] - YYYY-MM-DD` section to `CHANGELOG.md`.
3. Commit on `main` and push.
4. Run:

```bash
./scripts/release.sh
```

This runs analyze + tests, creates an annotated tag `vX.Y.Z`, and pushes it.  
The **Release** GitHub Action then re-verifies the tag, runs tests, creates a GitHub Release, publishes to **pub.dev** (OIDC; requires Automated publishing enabled for this repo), and deploys the example catalog to **GitHub Pages**. A push to `main` also deploys Pages after CI tests pass.

Dry-run:

```bash
./scripts/release.sh --dry-run
```

## CI

| Workflow | Trigger | What it does |
|----------|---------|----------------|
| [CI](.github/workflows/ci.yml) | push/PR to `main`, workflow_dispatch | version check, analyze, package + example tests; on `main` after tests: build `example/` web and deploy [GitHub Pages](https://zyzto.github.io/Edadat/) |
| [Release](.github/workflows/release.yml) | tag `v*.*.*` | tag↔pubspec check, CHANGELOG check, tests, GitHub Release, pub.dev publish, GitHub Pages |
