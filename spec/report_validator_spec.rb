# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SousChefsStats::ReportValidator do
  let(:repositories) { [{ 'name' => 'apt' }, { 'name' => 'nginx' }] }

  it 'accepts a section for every discovered repository' do
    report = <<~MARKDOWN
      # Sous-Chefs Weekly Repository Stats - 2026-08-10

      *_[sous-chefs/apt](https://github.com/sous-chefs/apt) Stats_*
      * PR Stats:
          * Closed PRs: 1
          * Open PRs: 2 (1 opened this period)
          * Stale PR (>30 days without comment): 0
      * Issue Stats:
          * Closed Issues: 1
          * Open Issues: 2 (1 opened this period)
          * Stale Issue (>30 days without comment): 0
      *_[sous-chefs/nginx](https://github.com/sous-chefs/nginx) Stats_*
      * PR Stats:
          * Closed PRs: 0
          * Open PRs: 0 (0 opened this period)
          * Stale PR (>30 days without comment): 0
      * Issue Stats:
          * Closed Issues: 0
          * Open Issues: 0 (0 opened this period)
          * Stale Issue (>30 days without comment): 0
    MARKDOWN
    expect { described_class.new.validate!(report:, repositories:) }.not_to raise_error
  end

  it 'rejects partial output' do
    report = "# Sous-Chefs Weekly Repository Stats - 2026-08-10\n\n*_[sous-chefs/apt](https://github.com/sous-chefs/apt) Stats_*\n* PR Stats:\n"
    expect { described_class.new.validate!(report:, repositories:) }.to raise_error(/coverage incomplete/)
  end

  it 'rejects headings without every required metric' do
    report = <<~MARKDOWN
      # Sous-Chefs Weekly Repository Stats - 2026-08-10

      *_[sous-chefs/apt](https://github.com/sous-chefs/apt) Stats_*
      * PR Stats:
      * Issue Stats:
      *_[sous-chefs/nginx](https://github.com/sous-chefs/nginx) Stats_*
      * PR Stats:
      * Issue Stats:
    MARKDOWN
    expect { described_class.new.validate!(report:, repositories:) }.to raise_error(/expected one closed PRs metric/)
  end

  it 'rejects duplicate sections that hide a missing repository' do
    report = <<~MARKDOWN
      # Sous-Chefs Weekly Repository Stats - 2026-08-10

      *_[sous-chefs/apt](https://github.com/sous-chefs/apt) Stats_*
      * PR Stats:
          * Closed PRs: 0
          * Open PRs: 0 (0 opened this period)
          * Stale PR (>30 days without comment): 0
      * Issue Stats:
          * Closed Issues: 0
          * Open Issues: 0 (0 opened this period)
          * Stale Issue (>30 days without comment): 0
      *_[sous-chefs/apt](https://github.com/sous-chefs/apt) Stats_*
      * PR Stats:
          * Closed PRs: 0
          * Open PRs: 0 (0 opened this period)
          * Stale PR (>30 days without comment): 0
      * Issue Stats:
          * Closed Issues: 0
          * Open Issues: 0 (0 opened this period)
          * Stale Issue (>30 days without comment): 0
    MARKDOWN
    expect { described_class.new.validate!(report:, repositories:) }.to raise_error(/repository names/)
  end
end
