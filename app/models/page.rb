# frozen_string_literal: true

class Page < ApplicationRecord
  validates :url, presence: true

  after_create :process_page

  def process_page
    ParsePageJob.perform_later self.id
  end
end
