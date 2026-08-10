# frozen_string_literal: true

module SousChefsStats
  class ReportValidator
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
          !section.include?('* Issue Stats:') ||
          !section.include?('* CI Stats:')
      end
      raise "report coverage incomplete: missing PR, issue, or CI data for #{incomplete.lines.first}" if incomplete
    end
  end
end
