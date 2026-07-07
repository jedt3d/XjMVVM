# Testing And Publishing

XjMVVM is not production-ready just because the code reads well. It needs repeatable proof.

[[diagram:ci-publishing|Validation and publishing flow from branch to live GitHub Pages.]]

## Local Checks

Use these checks before a pull request:

```bash
python3 tools/xojo_text_scan.py --root .
python3 tools/pocketbase_smoke.py
python3 tools/pocketbase_production_smoke.py
cd docs && npm ci && npm run build
```

The Xojo text scan catches malformed text-project tags and obvious source format problems. It does not replace opening the project in Xojo and running XojoUnit.

## XojoUnit

Use XojoUnit tests for:

- ViewModel behavior with fake repositories.
- Repository factory selection.
- SQLite adapter behavior.
- Direct SQL adapter behavior.
- PocketBase mapper, query, auth, and repository behavior that can be tested without a live server.

Use compiled/manual desktop tests for:

- Window bindings.
- URLConnection behavior.
- OS-specific file paths.
- Keychain or credential storage.
- Long-running background work.

## PocketBase Smokes

Two Python smokes cover server behavior:

- `tools/pocketbase_smoke.py` proves the public test contract against a disposable PocketBase instance.
- `tools/pocketbase_production_smoke.py` proves the committed owner-only production contract.

The production smoke is the more important release gate.

## GitHub Actions

The CI workflow validates docs, scans Xojo text, and runs PocketBase smokes on pull requests and pushes to `main`.

The Pages workflow builds `docs/site` and deploys it from GitHub Actions after `main` changes. The docs build removes stale generated HTML before writing the new guide, so old chapters do not remain published accidentally.

## Publishing Contract

Publishing the docs means:

1. Update guide source in `docs/book`.
2. Add or update diagrams in `docs/diagrams/svg`.
3. Run the docs build locally.
4. Commit source and generated `docs/site`.
5. Open a pull request.
6. Wait for CI.
7. Merge to `main`.
8. Wait for the Docs Pages workflow.
9. Verify `https://jedt3d.github.io/XjMVVM/`.

This is deliberately boring. Production documentation should be reproducible, not hand-edited on the live site.
