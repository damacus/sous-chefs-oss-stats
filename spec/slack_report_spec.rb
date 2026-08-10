# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SousChefsStats::SlackReport do
  it 'creates concise mrkdwn totals and a stale-repository watchlist' do
    report = <<~MARKDOWN
      # Sous-Chefs Weekly Repository Stats - 2026-08-10

      *_[sous-chefs/apt](https://github.com/sous-chefs/apt) Stats (Last 7 days)_*
      * PR Stats:
          * Closed PRs: 2
          * Open PRs: 4 (1 opened this period)
          * Stale PR (>30 days without comment): 3
      * Issue Stats:
          * Closed Issues: 1
          * Open Issues: 5 (2 opened this period)
          * Stale Issue (>30 days without comment): 6
      * CI Stats:
          * Branch: `main` has the following failures:
      *_[sous-chefs/nginx](https://github.com/sous-chefs/nginx) Stats (Last 7 days)_*
      * PR Stats:
          * Closed PRs: 1
          * Open PRs: 2 (0 opened this period)
          * Stale PR (>30 days without comment): 0
      * Issue Stats:
          * Closed Issues: 0
          * Open Issues: 1 (0 opened this period)
          * Stale Issue (>30 days without comment): 1
      * CI Stats:
          * Branch: `main`: No job failures found! :tada:
    MARKDOWN

    result = described_class.new.build(
      date: '2026-08-10', report:, repositories: [{}, {}]
    )

    expect(result).to include('Pull requests: *6 open*, 1 opened, 3 closed; 3 stale.')
    expect(result).to include('Issues: *6 open*, 2 opened, 1 closed; 7 stale.')
    expect(result).to include('CI: *1 repositories* have active GitHub Actions failures.')
    expect(result).to include('`apt` (6 stale)')
  end
end
