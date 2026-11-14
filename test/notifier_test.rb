# frozen_string_literal: true

require 'test_helper'

class TelegramNotifierTest < TelegramTestCase
  class SignupNotifier < Noticed::Ephemeral
    required_params :email

    bulk_deliver_by :telegram do |config|
      config.bot_token = TelegramTestCase::BOT_TOKEN
      config.chat_id = '-1001234567890'
      config.message_thread_id = 7
      config.text = -> { "New signup: #{params[:email]}" }
    end
  end

  class ReplyNotifier < Noticed::Ephemeral
    deliver_by :telegram do |config|
      config.bot_token = TelegramTestCase::BOT_TOKEN
      config.chat_id = -> { recipient }
      config.text = -> { "Hi, #{params[:name]}" }
    end
  end

  test 'bulk_deliver_by :telegram sends one message to the group thread' do
    # Noticed 2.x ephemeral notifiers drop the bulk config; persisted ones are unaffected.
    skip 'needs Noticed 3+' if Gem::Version.new(Noticed::VERSION) < Gem::Version.new('3')
    stub_telegram

    perform_enqueued_jobs { SignupNotifier.with(email: 'ada@example.com').deliver }

    assert_sent(chat_id: '-1001234567890', message_thread_id: 7, text: 'New signup: ada@example.com')
  end

  test 'deliver_by :telegram sends one message per recipient' do
    stub_telegram

    perform_enqueued_jobs { ReplyNotifier.with(name: 'Ada').deliver(%w[111 222]) }

    assert_sent(chat_id: '111', text: 'Hi, Ada')
    assert_sent(chat_id: '222', text: 'Hi, Ada')
  end
end
