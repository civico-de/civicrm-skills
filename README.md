# civicrm-skills

Agent Skills for contributing to [CiviCRM](https://civicrm.org) core:
finding your way around the project, reproducing bugs, writing tests and
catching regressions before a release. Packaged as a Claude Code plugin
marketplace; each skill is a plain `SKILL.md` and can be used by any agent
that reads the Agent Skills format.

## Skills

One plugin, `civicrm-core-dev`.

| Skill | Use it when |
|---|---|
| `civicrm-project-map` | finding your way: issue trackers, repositories, reading code, search order before reporting, branches and release cycle |
| `civikitchen` | a task needs a real CiviCRM instance: image and tag, booting a stack, core's test suites, comparing versions |
| `civicrm-verify-bug` | a bug is suspected: reproduce it in a disposable instance before reporting or fixing |
| `civicrm-tests` | writing tests: level, base class, fixtures, form and mail assertions, cleanup; the regression test for a fix; moving tests from APIv3 to APIv4 |
| `civicrm-pull-request` | your own change goes upstream: rules for the code, pull request with test, bot commands, or an issue when others' input is needed, or a private security report |
| `civicrm-review` | reviewing someone else's pull request: reproduce, validate, review standards, the review comment |
| `civicrm-ci-results` | a pull or merge request has a red or pending check: read which jobs and tests failed from the command line |
| `civicrm-release-regressions` | a version is about to ship or just shipped: compare it with the last one, find what broke, bisect and report |

## Agents

| Agent | What it does |
|---|---|
| `regression-triage` | reruns one test that passes on version A and fails on version B, alone, twice on B and once on A, and returns a verdict in a fixed format. `civicrm-release-regressions` starts one per test when an A/B run lists many. It runs fixed steps on a small model; the judging stays with the skill |

## Install

```bash
claude plugin marketplace add civico-de/civicrm-skills
claude plugin install civicrm-core-dev@civicrm-skills
```

## Requirements

The plugin installs the skills and connects the MCP server. The tools the
skills call are yours to set up:

| Needed for | What |
|---|---|
| reading and changing core's code | a local [civicrm-core](https://github.com/civicrm/civicrm-core) checkout |
| issues, pull and merge requests | the `gh` and `glab` command line clients, logged in |
| running an instance or core's tests | Docker; the skills pull [civikitchen](https://github.com/civico-de/civikitchen)'s images. A civikitchen checkout is needed only to build an image of a branch that has none |
| anything in the user interface | a browser the agent can drive, for example the Playwright MCP server or Claude in Chrome; any equivalent counts |

Optional:

- The `civicrm-knowledge` MCP server for searching across extensions,
  connected by the plugin ([MCP server](#mcp-server)); without it the
  skills clone what they need.
- A Jenkins login for the names and messages of failed tests
  ([CI details](#ci-details-optional)).

civikitchen's `ck demo` records before-and-after videos of fixed routes for
a person to watch, but does not let the agent explore a page. Without a
drivable browser the skills report the user interface as not verified
instead of guessing what a page does.

## MCP server

The plugin connects `civicrm-knowledge`, an MCP server run by civico at
`https://mcp.civico.de/mcp`. It searches an index of CiviCRM core, the
published extensions, the documentation and the public issue and pull
request discussions. Every skill works without it.

- The server is open for now: no account, no token, a rate limit per
  address. This may change.
- Open access covers the search and read tools over the public part of
  the index. A token adds code history and lifts the rate limit; write
  to johannes@civico.de for one.
- The server records every tool call to improve its search: the tool,
  its arguments, timing and the documents returned, with the IP address
  and client name. Do not put personal data or secrets into a query.

## CI details (optional)

Without any setup `civicrm-ci-results` reads which suites failed and how
many tests. The names and messages of the failed tests are in Jenkins on
test.civicrm.org, which needs a login:

1. Log in at https://test.civicrm.org with your civicrm.org account.
2. Open your user's settings there and create an API token.
3. Provide both to the agent's shell as environment variables, for example
   from a file outside any repository that your shell profile sources:

   ```bash
   export CIVICRM_JENKINS_USER=<your user name>
   export CIVICRM_JENKINS_TOKEN=<the token>
   ```

The skill's `scripts/jenkins.sh` reads them and passes them to curl on
stdin, so the token does not appear on a command line.

## Layout

```
.claude-plugin/marketplace.json     marketplace manifest
plugins/civicrm-core-dev/
  .claude-plugin/plugin.json        plugin manifest and version
  .mcp.json                         the civicrm-knowledge MCP server
  skills/<name>/SKILL.md            one skill per directory
  skills/<name>/references/*.md     read on demand, linked from SKILL.md
  skills/<name>/scripts/*           helper scripts a skill runs
  agents/<name>.md                  a subagent with its own model and steps
  evals/<case>/prompt.md            an eval case: one request to the agent
  evals/<case>/graders/*.md         what a good answer to it contains
  evals/fixtures/ck                 stand-in for `ck run` in agent cases
```

## Contributing

A rule goes into a skill when it has been checked against CiviCRM's source
or documentation, or run in an instance. A rule that cites its source
(a Developer Guide page, a file in civicrm-core) states upstream's policy;
an uncited rule is this repository's own working practice, often stricter
than upstream's. Bump the plugin version with every change to a skill or
an agent.

The eval cases hold decisions a skill has to get right, such as naming no
commit when a bisect did not confirm one. In the plugin directory,
`claude plugin eval . --tag skill` runs them with and without the plugin
and reports the difference; `--model` picks the model to check. The cases
tagged `agent` let the `regression-triage` agent run its steps against
`evals/fixtures/ck`, a stand-in that prints what `ck run` prints; they
need `--scaffold --allow-tools Bash`, and a machine on which Claude Code's
shell sandbox starts. Runs use tokens, so cap them with `--max-cost-usd`.

Security issues: security@civico.de.

## License

AGPL-3.0. See [LICENSE.md](LICENSE.md).
