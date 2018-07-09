# frozen_string_literal: true

class ParsePageJob < ApplicationJob
  queue_as :default

  def perform(id)
    page = Page.find(id)
    result = PageParser.call(url: page.url)
    set_attributes(page, result)
    page.save!
  rescue PageParser::Error => e
    page.error = error_message(e)
    page.save!
  end

  private

  def set_attributes(page, result)
    page.h1 = result.h1
    page.h2 = result.h2
    page.h3 = result.h3
    page.links = result.links
    page.parsed = true
  end

  def error_message(error)
    if error.is_a? PageParser::ConnectionError
      '520 Unknown Error' # This slowly becomes standard for catch-all error that should not happen
    else
      status_code = error.message
      status_text = Rack::Utils::HTTP_STATUS_CODES[error.message.to_i]
      "#{status_code} #{status_text}"
    end
  end
end
