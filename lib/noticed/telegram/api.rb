# frozen_string_literal: true

require 'json'
require 'net/http'

module Noticed
  module Telegram
    # sendMessage over the Telegram Bot API, shared by the individual and bulk
    # delivery methods.
    #
    # The request is made here rather than with Noticed's `post_request`
    # because the bot token is part of the URL path, and `post_request` puts
    # the full URL into the ResponseUnsuccessful message (and so into error
    # trackers). Every URL this module logs or raises with has the token
    # replaced by [FILTERED].
    module Api
      API_HOST = 'api.telegram.org'
      REDACTED_URL = "https://#{API_HOST}/bot[FILTERED]/sendMessage".freeze

      PASSTHROUGH_OPTIONS = %i[
        text
        message_thread_id
        parse_mode
        entities
        link_preview_options
        disable_web_page_preview
        disable_notification
        protect_content
        reply_markup
      ].freeze

      def self.included(base)
        base.required_options :bot_token, :chat_id
      end

      def deliver
        payload = json_payload
        response = send_message(payload)

        raise ResponseUnsuccessful.new(response, REDACTED_URL, { json: payload }) if raise_if_not_ok? && !ok?(response)

        response
      end

      def json_payload
        payload = { chat_id: evaluate_option(:chat_id) }
        PASSTHROUGH_OPTIONS.each do |option|
          payload[option] = evaluate_option(option) if config.key?(option)
        end

        return payload unless config.key?(:json)

        custom = evaluate_option(:json)
        custom.is_a?(Hash) ? payload.merge(custom.symbolize_keys) : custom
      end

      private

      def send_message(payload)
        logger.debug("POST #{REDACTED_URL}")

        response = Net::HTTP.start(API_HOST, 443, use_ssl: true, open_timeout: 5, read_timeout: 15) do |http|
          http.post("/bot#{evaluate_option(:bot_token)}/sendMessage", payload.to_json,
                    'Content-Type' => 'application/json')
        end

        logger.debug("Response: #{response.code}")
        response
      end

      # Telegram answers {"ok": true, ...} on success and {"ok": false, ...}
      # with a 4xx status on failure, so a send counts only when both agree.
      def ok?(response)
        response.is_a?(Net::HTTPSuccess) && JSON.parse(response.body.to_s)['ok'] == true
      rescue JSON::ParserError
        false
      end

      def raise_if_not_ok?
        config.key?(:raise_if_not_ok) ? evaluate_option(:raise_if_not_ok) : true
      end
    end
  end
end
