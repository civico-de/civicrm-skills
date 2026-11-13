# Review standards and gotchas

Source: `standards/review.md` in civicrm-dev-docs; read it when a case is
not covered here.

Standards (`standards/review.md`), each Pass or Issue:

| Code | Question |
|---|---|
| `r-explain` | Would a release-note editor or a later debugger understand what and why? Links do not replace a description |
| `r-user` | Does a user of the old version assimilate naturally, or is there a transition path? |
| `r-doc` | Does a guide need a matching pull request? |
| `r-run` | Was it used, proportionately? |
| `r-tech` | Does a contract change (APIv3, hook, PHP function or class, JS widget, CSS class)? Who calls it in core and in extensions? |
| `r-code` | Understandable, conventional, does it make the section better? |
| `r-maint` | A test or other protection, weighed against cost |
| `r-test` | Failures in CI explained |

Gotchas: `rg-pkg` new top-level files or types reach the tarballs, a
removed dangerous file is added to `checkFilesAreNotPresent`; `rg-perm`
existing installs keep working after a permission change; `rg-sec` data
between SQL, PHP, HTML and CLI escaped and validated (`security/inputs`,
`outputs`, `permissions`, `access`, `csrf`, summarised in
`references/code-changes.md` of `civicrm-pull-request`); `rg-setting`
deployments referencing an added or removed setting; `rg-upgrades` fresh
install and upgrade end with the same schema, helpers, batches,
multilingual strings; `rg-hook` a new hook parameter is semantically safe.

Also look for behaviour regressions, data integrity, install and upgrade
lifecycle, version compatibility, caches, whether the change sits at the
owning layer, silent fallbacks, and in UI changes ARIA state, live regions
and keyboard paths (`aria-hidden` does not exempt visible text from
contrast). For code that warns or flags, build the most plausible healthy
example per rule; a false alarm is a top finding.
