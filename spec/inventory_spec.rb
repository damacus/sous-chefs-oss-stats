# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SousChefsStats::Inventory do
  Response = Struct.new(:body, :code, :headers, keyword_init: true) do
    def [](key)
      headers[key]
    end

    def is_a?(klass)
      return true if klass == Net::HTTPSuccess

      super
    end
  end

  it 'keeps only active public non-fork repositories over every page' do
    first = Response.new(
      code: '200',
      body: JSON.generate([
                            { 'name' => 'active', 'visibility' => 'public', 'fork' => false, 'archived' => false, 'disabled' => false },
                            { 'name' => 'fork', 'visibility' => 'public', 'fork' => true, 'archived' => false, 'disabled' => false },
                          ]),
      headers: { 'link' => '<https://example.test/page=2>; rel="next"' }
    )
    second = Response.new(
      code: '200',
      body: JSON.generate([
                            { 'name' => 'archived', 'visibility' => 'public', 'fork' => false, 'archived' => true, 'disabled' => false },
                            { 'name' => 'another', 'visibility' => 'public', 'fork' => false, 'archived' => false, 'disabled' => false },
                          ]),
      headers: {}
    )
    client = instance_double(Net::HTTP)
    allow(client).to receive(:request).and_return(first, second)
    http = class_double(Net::HTTP)
    allow(http).to receive(:start).and_yield(client)

    repos = described_class.new(token: 'token', http:).fetch

    expect(repos.map { |repo| repo['name'] }).to eq(%w[active another])
  end

  it 'requires a token' do
    expect { described_class.new(token: '').fetch }.to raise_error(ArgumentError, /GITHUB_TOKEN/)
  end
end
