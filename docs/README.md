# XjMVVM Docs

This folder adapts the Pi Analysis Docs framework for XjMVVM documentation,
review, and publishing.

## Commands

```bash
cd docs
npm install
npm run build
npm run read
```

Open the reader at:

```text
http://localhost:8000/site/
```

Use `npm run comments` to list reader comments saved in
`reader/comments.json`.

## Notes

- The generated pages in `site/` are self-contained HTML.
- The reader/comment API is active only when served by `npm run read`.
- Snippet directives read from the XjMVVM repository root by default.
- Set `XJMVVM_REPO_READ` or `XJMVVM_REPO_HOST` only when the source root or
  VS Code jump-link root differs.

