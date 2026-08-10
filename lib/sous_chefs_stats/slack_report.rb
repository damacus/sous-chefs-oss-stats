# frozen_string_literal: true

module SousChefsStats
  class SlackReport
    def build(date:, report:, repositories:)
      metrics = totals(report)
      watchlist = stale_watchlist(report)

      lines = [
        "*Sous-Chefs weekly update - #{date}*",
        "GitHub health across *#{repositories.length}* active public non-fork repositories.",
        '',
        '*This week*',
        "- Pull requests: *#{metrics[:pr_open]} open*; #{metrics[:pr_opened]} still open and created this week; #{metrics[:pr_closed]} closed; #{metrics[:pr_stale]} stale.",
        "- Issues: *#{metrics[:issue_open]} open*; #{metrics[:issue_opened]} still open and created this week; #{metrics[:issue_closed]} closed; #{metrics[:issue_stale]} stale.",
      ]
      lines << "- Watchlist: #{watchlist.join(', ')}." unless watchlist.empty?
      lines << ''
      lines << 'Please help review the watchlist or flag a repository that should not be included.'
      lines.join("\n") + "\n"
    end

    private

    def totals(report)
      {
        pr_open: sum(report, /^\s*\* Open PRs: (\d+) \((\d+) opened this period\)/),
        pr_opened: sum(report, /^\s*\* Open PRs: \d+ \((\d+) opened this period\)/),
        pr_closed: sum(report, /^\s*\* Closed PRs: (\d+)/),
        pr_stale: sum(report, /^\s*\* Stale PR \(>30 days without comment\): (\d+)/),
        issue_open: sum(report, /^\s*\* Open Issues: (\d+) \((\d+) opened this period\)/),
        issue_opened: sum(report, /^\s*\* Open Issues: \d+ \((\d+) opened this period\)/),
        issue_closed: sum(report, /^\s*\* Closed Issues: (\d+)/),
        issue_stale: sum(report, /^\s*\* Stale Issue \(>30 days without comment\): (\d+)/),
      }
    end

    def sum(report, pattern)
      report.scan(pattern).sum { |match| match.first.to_i }
    end

    def stale_watchlist(report)
      report.split(/^\*_\[/).map do |section|
        name = section[/\Asous-chefs\/([^\]]+)/, 1]
        stale = section.scan(/^\s*\* Stale (?:PR|Issue) \(>30 days without comment\): (\d+)/).flatten.sum(&:to_i)
        "`#{name}` (#{stale} stale)" if name && stale.to_i.positive?
      end.compact.sort_by { |entry| -entry[/\((\d+) stale\)/, 1].to_i }.first(3)
    end
  end
end
