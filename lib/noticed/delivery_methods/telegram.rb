# frozen_string_literal: true

module Noticed
  module DeliveryMethods
    # One message per recipient, e.g. to each user's private chat with your bot.
    class Telegram < DeliveryMethod
      include Noticed::Telegram::Api
    end
  end
end

ActiveSupport.run_load_hooks :noticed_delivery_methods_telegram, Noticed::DeliveryMethods::Telegram
