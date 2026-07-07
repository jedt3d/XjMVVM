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

## Candidate Publish Paths

The first recommended path is GitHub Pages from this same repository:

- source: `main` branch,
- folder: `/docs/site` if GitHub Pages supports the selected folder layout, or
- a `gh-pages` branch populated from `docs/site` if a root-only Pages branch is
  cleaner.

Do not publish automatically until the repository owner chooses the Pages
layout. The current implementation cycle only proves that the site builds and
can be reviewed locally.
