# Publishing The XjMVVM Docs

The docs system is intentionally source-first:

1. edit Markdown in `docs/book/`,
2. run `npm run build`,
3. review locally with `npm run read`,
4. process reader comments with `npm run comments`,
5. commit the source and generated `docs/site/` output on a feature branch,
6. open a pull request before publishing.

## Current GitHub Connection

The local checkout remote is:

```text
https://github.com/jedt3d/XjMVVM.git
```

Use GitHub best practice for changes:

- work on a feature branch,
- keep generated docs and source docs in the same review when the output is
  intentionally tracked,
- avoid committing unrelated `.xojo_project`, `.DS_Store`, local database, or
  IDE state changes,
- open a pull request for review before merging to `main`.

## Publishing Path

The docs publish from GitHub Actions:

- workflow: `.github/workflows/docs-pages.yml`
- source branch: `main`
- build command: `cd docs && npm ci && npm run build`
- published artifact: `docs/site`
- Pages environment: `github-pages`

The workflow uses GitHub's Pages artifact deployment flow instead of a
`gh-pages` branch. That keeps the published output tied to the CI run that
built and uploaded it.

## CI Gates

Pull requests and pushes to `main` run `.github/workflows/ci.yml`, which checks:

- docs dependency install and static build,
- lightweight Xojo text-project structure through `tools/xojo_text_scan.py`,
- public stock PocketBase CRUD smoke,
- production PocketBase owner-rule smoke.

Local Xojo Analyze remains the compiler gate because hosted GitHub runners do
not include the Xojo IDE.
