# frozen_string_literal: true

require_relative 'lib/noticed/telegram/version'

Gem::Specification.new do |spec|
  spec.name = 'noticed-telegram'
  spec.version = Noticed::Telegram::VERSION
  spec.authors = ['Yaroslav Shmarov']
  spec.email = ['yaroslav.shmarov@clickfunnels.com']

  spec.summary = 'Telegram delivery methods for Noticed: deliver_by :telegram and bulk_deliver_by :telegram.'
  spec.description = <<~DESC
    Send Noticed notifications through the Telegram Bot API: one message per
    recipient with `deliver_by :telegram`, or one message to a group, forum
    topic, or channel with `bulk_deliver_by :telegram`. The bot token is kept
    out of logs and error messages.
  DESC
  spec.homepage = 'https://github.com/yshmarov/noticed-telegram'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*', 'MIT-LICENSE', 'README.md', 'CHANGELOG.md', 'SECURITY.md']
  spec.require_paths = ['lib']

  spec.add_dependency 'noticed', '>= 2.0', '< 4'
end
