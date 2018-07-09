# frozen_string_literal: true

Rails.application.routes.draw do
  jsonapi_resources :pages, except: %i[update destroy]
end
