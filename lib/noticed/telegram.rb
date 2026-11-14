# frozen_string_literal: true

require 'noticed'
require 'noticed/telegram/version'

# Noticed resolves `deliver_by :telegram` to Noticed::DeliveryMethods::Telegram
# at delivery time. The classes are autoloaded rather than required because
# their superclasses inherit from Noticed::ApplicationJob, which only exists
# once the host app's autoloaders are running.
module Noticed
  module Telegram
    autoload :Api, 'noticed/telegram/api'
  end

  module DeliveryMethods
    autoload :Telegram, 'noticed/delivery_methods/telegram'
  end

  module BulkDeliveryMethods
    autoload :Telegram, 'noticed/bulk_delivery_methods/telegram'
  end
end
