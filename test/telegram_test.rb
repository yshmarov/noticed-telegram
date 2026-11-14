# frozen_string_literal: true

require 'test_helper'

class TelegramTest < TelegramTestCase
  setup do
    @delivery_method = Noticed::BulkDeliveryMethods::Telegram.new
    configure(bot_token: BOT_TOKEN, chat_id: '-1001234567890', text: 'New signup')
  end

  test 'sends the chat id and text' do
    stub_telegram

    @delivery_method.deliver

    assert_sent(chat_id: '-1001234567890', text: 'New signup')
  end

  test 'passes through supported Bot API options' do
    configure(bot_token: BOT_TOKEN, chat_id: '-1001234567890', text: '<b>Alert</b>', message_thread_id: 42,
              parse_mode: 'HTML', disable_notification: true)
    stub_telegram

    @delivery_method.deliver

    assert_sent(chat_id: '-1001234567890', text: '<b>Alert</b>', message_thread_id: 42, parse_mode: 'HTML',
                disable_notification: true)
  end

  test 'merges a custom json payload over the defaults' do
    keyboard = { inline_keyboard: [[{ text: 'View', url: 'https://example.com' }]] }
    configure(bot_token: BOT_TOKEN, chat_id: '-1001234567890', text: 'New order', json: { reply_markup: keyboard })
    stub_telegram

    @delivery_method.deliver

    assert_sent(chat_id: '-1001234567890', text: 'New order', reply_markup: keyboard)
  end

  test 'raises on an error status' do
    stub_telegram(status: 400, body: { ok: false, description: 'Bad Request: chat not found' })

    assert_raises(Noticed::ResponseUnsuccessful) { @delivery_method.deliver }
  end

  test 'raises on a success status whose body says ok: false' do
    stub_telegram(body: { ok: false, description: 'Bad Request' })

    assert_raises(Noticed::ResponseUnsuccessful) { @delivery_method.deliver }
  end

  test 'returns the response without raising when raise_if_not_ok is false' do
    configure(bot_token: BOT_TOKEN, chat_id: '-1001234567890', text: 'New signup', raise_if_not_ok: false)
    stub_telegram(status: 403, body: { ok: false, description: 'Forbidden: bot was blocked by the user' })

    assert_equal '403', @delivery_method.deliver.code
  end

  test 'keeps the bot token out of the error message' do
    stub_telegram(status: 401, body: { ok: false, description: 'Unauthorized' })

    error = assert_raises(Noticed::ResponseUnsuccessful) { @delivery_method.deliver }

    assert_not_includes error.message, BOT_TOKEN
    assert_includes error.message, 'bot[FILTERED]/sendMessage'
  end

  test 'requires a bot token and chat id' do
    assert_equal %i[bot_token chat_id], Noticed::BulkDeliveryMethods::Telegram.required_option_names
    assert_equal %i[bot_token chat_id], Noticed::DeliveryMethods::Telegram.required_option_names
  end

  private

  def configure(config)
    @delivery_method.instance_variable_set(:@config, ActiveSupport::HashWithIndifferentAccess.new(config))
  end
end
