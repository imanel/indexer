# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'

class PageParser
  class Error < StandardError; end
  class ConnectionError < Error; end
  class FetchingError < Error; end

  attr_reader :data, :url, :h1, :h2, :h3, :links

  def self.call(url:)
    instance = new(url: url)
    instance.fetch
    instance.parse
    instance
  end

  def initialize(data: nil, url: nil)
    @data = data
    @url = url
    @h1 = []
    @h2 = []
    @h3 = []
    @links = []
  end

  def fetch
    raise ArgumentError, 'no URL provided' if @url.nil?
    response = fetch_url(url: @url.to_s)
    raise FetchingError, response.status.to_s unless response.success?
    @data = response.body
  end

  def parse
    raise ArgumentError, 'no data provided' if @data.nil?
    html_doc = Nokogiri::HTML(@data.to_s)
    @h1 = parse_tag(document: html_doc, selector: :h1)
    @h2 = parse_tag(document: html_doc, selector: :h2)
    @h3 = parse_tag(document: html_doc, selector: :h3)
    @links = parse_tag(document: html_doc, selector: :a, attribute: :href)
    nil
  end

  private

  def fetch_url(url:)
    connection = Faraday.new(url: url) do |faraday|
      faraday.use FaradayMiddleware::FollowRedirects
      faraday.adapter Faraday.default_adapter
    end

    connection.get
  rescue StandardError => e
    # Why are we catching something as broad as StandardError? Faraday is using Net::HTTP under the hood, which can
    # generate number of random errors, ranging from URI, through ArtumentError, all the way to SocketError. Writing
    # them all down is close to impossible, so it's easier to catch StandardError and assume it's ConnectionError.
    raise ConnectionError, e
  end

  def parse_tag(document:, selector:, attribute: nil)
    document.css(selector.to_s).map do |elem|
      attribute ? elem.attr(attribute.to_s) : elem.text
    end.compact
  end
end
