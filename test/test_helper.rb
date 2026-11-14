# frozen_string_literal: true

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'noticed'
require 'noticed/telegram'
require 'minitest/autorun'
require 'webmock/minitest'

class Dummy < Rails::Application
  config.root = __dir__
  config.eager_load = false
  config.logger = Logger.new(nil)
  config.secret_key_base = 'test'
  config.active_job.queue_adapter = :test
end
Rails.application.initialize!

class TelegramTestCase < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  BOT_TOKEN = '123456:TEST-TOKEN'
  API_URL = "https://api.telegram.org/bot#{BOT_TOKEN}/sendMessage".freeze

  def stub_telegram(status: 200, body: { ok: true, result: { message_id: 1 } })
    stub_request(:post, API_URL).to_return(status: status, body: body.to_json,
                                           headers: { 'Content-Type' => 'application/json' })
  end

  def assert_sent(payload)
    assert_requested :post, API_URL, body: payload, headers: { 'Content-Type' => 'application/json' }
  end
end
