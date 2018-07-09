# frozen_string_literal: true

class PageResource < JSONAPI::Resource
  attributes :url, :h1, :h2, :h3, :links, :parsed, :error, :created_at, :updated_at

  def self.creatable_fields(_context)
    [:url]
  end

  def self.sortable_fields(_context)
    [:id]
  end
end
