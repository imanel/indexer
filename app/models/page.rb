# frozen_string_literal: true

class Page < ApplicationRecord
  validates :url, presence: true
end
