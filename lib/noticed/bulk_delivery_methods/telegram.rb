# frozen_string_literal: true

module Noticed
  module BulkDeliveryMethods
    # One message per event, e.g. to a team group chat or a channel.
    class Telegram < BulkDeliveryMethod
      include Noticed::Telegram::Api
    end
  end
end

ActiveSupport.run_load_hooks :noticed_bulk_delivery_methods_telegram, Noticed::BulkDeliveryMethods::Telegram
