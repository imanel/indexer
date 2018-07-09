# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ParsePageJob, type: :job do
  let(:page) { Page.create(url: url) }
  let(:h1) { [] }
  let(:h2) { [] }
  let(:h3) { [] }
  let(:links) { [] }
  let(:parsed) { false }
  let(:error) { nil }

  context 'when Page url is invalid' do
    let(:url) { 'invalid' }
    let(:error) { '520 Unknown Error' }

    include_examples 'page verification'
  end

  context 'when Page url returns error 500' do
    let(:url) { 'http://test.com' }
    let(:error) { '500 Internal Server Error' }

    before { stub_request(:get, 'http://test.com').and_return(status: 500) }

    include_examples 'page verification'
  end

  context 'when Page url returns error 404' do
    let(:url) { 'http://test.com' }
    let(:error) { '404 Not Found' }

    before { stub_request(:get, 'http://test.com').and_return(status: 404) }

    include_examples 'page verification'
  end

  context 'when Page url returns content' do
    let(:url) { 'http://test.com' }
    let(:data) do
      <<~HTML
        <body>
          <h1>Hello h1</h1>
          <h2>Hello h2</h2>
          <h3>Hello h3</h3>
          <a href='Link URL'>Hello link</a>
        </body>
      HTML
    end
    let(:h1) { ['Hello h1'] }
    let(:h2) { ['Hello h2'] }
    let(:h3) { ['Hello h3'] }
    let(:links) { ['Link URL'] }
    let(:parsed) { true }

    before { stub_request(:get, 'http://test.com').and_return(body: data, status: 200) }

    include_examples 'page verification'
  end
end
