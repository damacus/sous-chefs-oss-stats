# frozen_string_literal: true

module SousChefsStats
  class ReportValidator
    REQUIRED_METRICS = {
      'closed PRs' => /^\s*\* Closed PRs: \d+$/,
      'open PRs' => /^\s*\* Open PRs: \d+ \(\d+ opened this period\)$/,
      'stale PRs' => /^\s*\* Stale PR \(>30 days without comment\): \d+$/,
      'closed issues' => /^\s*\* Closed Issues: \d+$/,
      'open issues' => /^\s*\* Open Issues: \d+ \(\d+ opened this period\)$/,
      'stale issues' => /^\s*\* Stale Issue \(>30 days without comment\): \d+$/,
    }.freeze

    def validate!(report:, repositories:)
      raise 'report is missing its title' unless report.start_with?('# Sous-Chefs Weekly Repository Stats - ')
      raise 'report contains an oss-stats error' if report.match?(/(?:^|\n)(?:ERROR|FATAL|\[ERROR\])/)

      sections = report.split(/^\*_\[/).drop(1)
      expected = repositories.length
      unless sections.length == expected
        raise "report coverage incomplete: expected #{expected} repository sections, found #{sections.length}"
      end

      reported_names = sections.filter_map { |section| section[/\Asous-chefs\/([^\]]+)/, 1] }.sort
      expected_names = repositories.map { |repo| repo.fetch('name') }.sort
      unless reported_names == expected_names
        raise 'report coverage incomplete: repository names do not match the saved inventory'
      end

      incomplete = sections.find do |section|
        !section.include?('* PR Stats:') ||
          !section.include?('* Issue Stats:')
      end
      raise "report coverage incomplete: missing PR or issue data for #{incomplete.lines.first}" if incomplete

      sections.each do |section|
        REQUIRED_METRICS.each do |label, pattern|
          count = section.scan(pattern).length
          next if count == 1

          raise "report coverage incomplete: expected one #{label} metric for #{section.lines.first.strip}, found #{count}"
        end
      end
    end
  end
end
