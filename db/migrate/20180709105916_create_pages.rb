# frozen_string_literal: true

class CreatePages < ActiveRecord::Migration[5.2]
  def change
    create_table :pages do |t|
      t.text :url, null: false
      t.text :h1, array: true, default: []
      t.text :h2, array: true, default: []
      t.text :h3, array: true, default: []
      t.text :links, array: true, default: []
      t.boolean :parsed, default: false
      t.string :error

      t.timestamps
    end
  end
end
