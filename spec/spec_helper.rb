# frozen_string_literal: true

require 'tmpdir'

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'sous_chefs_stats/inventory'
require 'sous_chefs_stats/repo_report'
require 'sous_chefs_stats/report_validator'
require 'sous_chefs_stats/slack_report'
