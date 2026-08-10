# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

module SousChefsStats
  # Retrieves the source-of-truth repository inventory. The filters deliberately
  # exclude archived, disabled, and forked projects from the weekly health view.
  class Inventory
    ORG = 'sous-chefs'
    API_URL = "https://api.github.com/orgs/#{ORG}/repos?type=public&per_page=100"

    def initialize(token:, http: Net::HTTP)
      @token = token
      @http = http
    end

    def fetch
      raise ArgumentError, 'GITHUB_TOKEN is required to discover repositories' if @token.to_s.empty?

      repositories = []
      next_url = API_URL
      while next_url
        response = get(next_url)
        unless response.is_a?(Net::HTTPSuccess)
          raise "GitHub repository discovery failed: HTTP #{response.code} #{response.body}"
        end

        repositories.concat(JSON.parse(response.body))
        next_url = next_page(response['link'])
      end

      repositories
        .select { |repo| repo['visibility'] == 'public' && !repo['fork'] && !repo['archived'] && !repo['disabled'] }
        .sort_by { |repo| repo.fetch('name').downcase }
    end

    private

    def get(url)
      uri = URI(url)
      request = Net::HTTP::Get.new(uri)
      request['Accept'] = 'application/vnd.github+json'
      request['Authorization'] = "Bearer #{@token}"
      request['User-Agent'] = 'sous-chefs-oss-stats'
      @http.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |client|
        client.request(request)
      end
    end

    def next_page(link_header)
      return nil if link_header.to_s.empty?

      match = link_header.match(/<([^>]+)>;\s*rel="next"/)
      match && match[1]
    end
  end
end
