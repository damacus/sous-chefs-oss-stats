# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SousChefsStats::RepoReport do
  it 'uses each discovered default branch and rate-bounded oss-stats modes' do
    status = instance_double(Process::Status, success?: true)
    runner = class_double(Open3)
    allow(runner).to receive(:capture3).and_return(['*_[sous-chefs/apt](https://github.com/sous-chefs/apt) Stats_*', '', status])
    root = Dir.mktmpdir
    repositories = [{ 'name' => 'apt', 'default_branch' => 'master' }]

    report = described_class.new(root: root, runner: runner).generate(
      date: '2026-08-10', repositories: repositories, token: 'token'
    )

    expect(report).to include('Inventory coverage: 1 active public non-fork repositories.')
    config = File.read(File.join(root, 'tmp', 'repo_stats_config-2026-08-10.rb'))
    expect(config).to include('"branches" => ["master"]')
    expect(runner).to have_received(:capture3).with(
      { 'GITHUB_TOKEN' => 'token', 'GH_TOKEN' => 'token' },
      'bundle', 'exec', 'repo_stats', '--config', File.join(root, 'tmp', 'repo_stats_config-2026-08-10.rb'),
      '--mode', 'pr,issue', chdir: root
    )
  end
end
