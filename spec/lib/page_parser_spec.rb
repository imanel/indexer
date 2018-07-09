# frozen_string_literal: true

require 'rails_helper'

describe PageParser do
  context 'when .call is called with URL' do
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
    let(:url) { 'http://test.com' }
    let(:result) { described_class.call(url: url) }

    before { stub_request(:get, url).to_return(body: data, status: 200) }

    it 'extracts h1' do
      expect(result.h1).to eql ['Hello h1']
    end
    it 'extracts h2' do
      expect(result.h2).to eql ['Hello h2']
    end
    it 'extracts h3' do
      expect(result.h3).to eql ['Hello h3']
    end
    it 'extracts links' do
      expect(result.links).to eql ['Link URL']
    end
  end

  context 'when #fetch is called' do
    it 'raises ArgumentError if no URL provided' do
      instance = described_class.new(url: nil)
      expect { instance.fetch }.to raise_error ArgumentError, 'no URL provided'
    end
    it 'raises ConnectionError if URL has invalid format' do
      instance = described_class.new(url: 'invalid')
      expect { instance.fetch }.to raise_error PageParser::ConnectionError
    end
    it 'raises ConnectionError if URL has invalid protocol' do
      instance = described_class.new(url: 'file://test')
      expect { instance.fetch }.to raise_error PageParser::ConnectionError
    end
    it 'raises FetchingError if server error occurs' do
      stub_request(:get, 'test.com').to_return(status: 500)
      instance = described_class.new(url: 'http://test.com')
      expect { instance.fetch }.to raise_error PageParser::FetchingError, '500'
    end
    it 'raises FetchingError if not found occurs' do
      stub_request(:get, 'test.com').to_return(status: 404)
      instance = described_class.new(url: 'http://test.com')
      expect { instance.fetch }.to raise_error PageParser::FetchingError, '404'
    end
    it 'returns data if server connection is valid' do
      stub_request(:get, 'test.com').to_return(body: 'Test payload', status: 200)
      instance = described_class.new(url: 'http://test.com')
      expect(instance.fetch).to eql('Test payload')
    end
    it 'sets data if server connection is valid' do
      stub_request(:get, 'test.com').to_return(body: 'Test payload', status: 200)
      instance = described_class.new(url: 'http://test.com')
      instance.fetch
      expect(instance.data).to eql('Test payload')
    end
    it 'follows redirects' do
      stub_request(:get, 'test.com').to_return(headers: { 'Location' => 'http://test2.com' }, status: 301)
      stub_request(:get, 'test2.com').to_return(body: 'Test payload', status: 200)
      instance = described_class.new(url: 'http://test.com')
      expect(instance.fetch).to eql('Test payload')
    end
    it 'raises ConnectionError if too many redirects are present' do
      stub_request(:get, 'test.com').to_return(headers: { 'Location' => 'http://test2.com' }, status: 301)
      stub_request(:get, 'test2.com').to_return(headers: { 'Location' => 'http://test.com' }, status: 301)
      instance = described_class.new(url: 'http://test.com')
      expect { instance.fetch }.to raise_error PageParser::ConnectionError,
                                               'too many redirects; last one to: http://test.com'
    end
  end

  context 'when #parse is called' do
    it 'raises ArgumentError if no data is set' do
      instance = described_class.new(data: nil)
      expect { instance.parse }.to raise_error ArgumentError, 'no data provided'
    end
    it 'returns nil if invalid data is provided' do
      instance = described_class.new(data: 'invalid')
      expect(instance.parse).to be nil
    end
    it 'extracts h1 tag content if available in data' do
      instance = described_class.new(data: '<body><h1>First text</h1><h1>Second text</h1><body>')
      instance.parse
      expect(instance.h1).to eql ['First text', 'Second text']
    end
    it 'extracts h1 tags even if they are on different nesting level' do
      instance = described_class.new(data: '<body><h1>First text</h1><div><h1>Second text</h1><div><body>')
      instance.parse
      expect(instance.h1).to eql ['First text', 'Second text']
    end
    it 'extracts h1 tags even if syntax is malformed' do
      instance = described_class.new(data: '<body><h1>First text</h1><h1>Second text</body>')
      instance.parse
      expect(instance.h1).to eql ['First text', 'Second text']
    end
    it 'extracts h2 tag content if available in data' do
      instance = described_class.new(data: '<body><h2>First text</h2><h2>Second text</h2><body>')
      instance.parse
      expect(instance.h2).to eql ['First text', 'Second text']
    end
    it 'extracts h3 tag content if available in data' do
      instance = described_class.new(data: '<body><h3>First text</h3><h3>Second text</h3><body>')
      instance.parse
      expect(instance.h3).to eql ['First text', 'Second text']
    end
    it 'extracts link URL if available in data' do
      instance = described_class.new(
        data: '<body><a href="First link">First text</a><a href="Second link">Second text</a><body>'
      )
      instance.parse
      expect(instance.links).to eql ['First link', 'Second link']
    end
    it 'ignore "a" tags without href' do
      instance = described_class.new(
        data: '<body><a href="First link">First text</a><a>Second text</a><body>'
      )
      instance.parse
      expect(instance.links).to eql ['First link']
    end
  end
end
