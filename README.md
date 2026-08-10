# Sous-Chefs OSS Stats Trial

This is a public-repository-ready trial for a weekly Sous-Chefs health report.
It discovers the current active public, non-fork repositories from the GitHub
organization API every run, then asks [oss-stats](https://github.com/jaymzh/oss-stats)
for GitHub PR and issue statistics. It does not query Buildkite or enumerate
GitHub Actions workflows, and does not post to Slack or n8n.

## Artifacts

Each run writes three dated, reviewable artifacts:

- `repository_inventory/YYYY-MM-DD.json`: raw GitHub inventory used for that run.
- `repo_reports/YYYY-MM-DD.md`: canonical detailed report from `oss-stats`.
- `slack_reports/YYYY-MM-DD.md`: concise Slack `mrkdwn` suitable for a downstream publisher.

The generator rejects empty output, explicit `oss-stats` errors, or a report
whose repository sections or metrics differ from the saved inventory. This
prevents a partial report from looking successful.

## Local Run

```sh
bundle install
GITHUB_TOKEN="$(gh auth token)" bundle exec ruby bin/generate_weekly_report
bundle exec rspec
```

`GITHUB_TOKEN` is the only credential. The scheduled workflow runs at 14:00
UTC every Thursday, which is before 17:00 Europe/London in both GMT and BST,
and opens or fast-forwards a pull request containing the three artifacts. It
intentionally makes no Slack or n8n call, so publishing remains a separate,
reviewable decision.

CI health is deliberately outside this trial. Scanning every workflow in the
organization would exceed a repository `GITHUB_TOKEN` request budget; it needs
a separate rate-efficient collector rather than silently publishing partial CI
coverage.

## Trial Exit Criteria

1. The Thursday workflow creates a complete pull request with all three artifacts.
2. A reviewer confirms the Slack artifact is useful in `#community-meetings`.
3. Only then connect the Slack artifact to the authenticated n8n publisher.

## License

Apache-2.0. See `LICENSE`.
