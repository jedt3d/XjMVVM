# CI And Docs Publishing

Cycle 9 closes the framework production loop with GitHub Actions validation and
GitHub Pages publishing.

## Workflows

The repository now has two workflows:

- `CI` runs on pull requests, pushes to `main`, and manual dispatch.
- `Docs Pages` runs on pushes to `main` and manual dispatch.

`CI` validates the framework with:

- `npm ci` and `npm run build` in `docs/`
- `tools/xojo_text_scan.py`
- `tools/pocketbase_smoke.py`
- `tools/pocketbase_production_smoke.py`

`Docs Pages` rebuilds the docs, runs the same lightweight Xojo text scan, uploads
`docs/site`, and deploys the artifact to GitHub Pages.

## Why The Xojo Scan Is Lightweight

Hosted Linux runners do not have the Xojo IDE. The CI scan is therefore a
source-control gate, not a compiler. It checks:

- conflict markers
- Xojo `#tag` balance
- local manifest paths

Xojo Analyze remains the local/macOS compiler gate before source releases.

## Publishing Model

Publishing uses a custom GitHub Actions workflow rather than the legacy branch
folder setting. This keeps the generated docs artifact tied to the validated
build that produced it.

The published site root is the generated static site:

```text
docs/site
```

## Maintenance

Dependabot is configured for:

- GitHub Actions versions
- docs npm dependencies

That keeps the publishing pipeline from silently aging around action/runtime
deprecations.

## Remaining Boundary

After this phase, the framework baseline is done. The next work should be a
sample application that consumes the framework and proves the production
patterns with a real app workflow.
