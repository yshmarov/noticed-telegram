# noticed-telegram

Telegram delivery methods for [Noticed](https://github.com/excid3/noticed).

- `bulk_deliver_by :telegram` sends **one message per event**, to a group, a forum topic, or a channel. Use it for team alerts like "new signup" or "payment failed".
- `deliver_by :telegram` sends **one message per recipient**, to each user's private chat with your bot.

Both call the Bot API's [`sendMessage`](https://core.telegram.org/bots/api#sendmessage). The bot token is part of Telegram's URL, so this gem keeps it out of Noticed's logs and out of `Noticed::ResponseUnsuccessful` messages, which usually end up in your error tracker.

Works with Noticed 2.x and 3.x on Rails 7.1+.

## Install

```ruby
# Gemfile
gem "noticed-telegram"
```

Nothing else: once the gem is in the bundle, Noticed finds `:telegram`.

## Set up a bot

1. Message [@BotFather](https://t.me/botfather), send `/newbot`, and copy the token.
2. Store it in credentials, e.g. `telegram: { bot_token: "..." }`.
3. Find the chat ID:
   - **Group or forum:** add the bot to the group, send a message there, then open `https://api.telegram.org/bot<TOKEN>/getUpdates` and read `message.chat.id` (it starts with `-100`). In a forum topic, `message.message_thread_id` is the topic ID.
   - **Channel:** add the bot as an admin and use `@channelname` or the numeric `-100…` ID.
   - **A user:** the user must message your bot first; their `chat.id` then appears in `getUpdates` (or in your webhook). Store it on the user.

## Team alerts: `bulk_deliver_by :telegram`

```ruby
class NewSignupNotifier < Noticed::Event
  bulk_deliver_by :telegram do |config|
    config.bot_token = Rails.application.credentials.dig(:telegram, :bot_token)
    config.chat_id = "-1001234567890"
    config.message_thread_id = 42 # optional: post into one forum topic
    config.text = -> { "New signup: #{params[:user].email}" }
  end
end

NewSignupNotifier.with(user: user).deliver
```

Procs run in the context of the event, so `params` and `record` are available.

## Per-user messages: `deliver_by :telegram`

```ruby
class CommentNotifier < Noticed::Event
  deliver_by :telegram do |config|
    config.bot_token = Rails.application.credentials.dig(:telegram, :bot_token)
    config.chat_id = -> { recipient.telegram_chat_id }
    config.text = -> { "<b>#{params[:comment].author_name}</b> replied to you" }
    config.parse_mode = "HTML"
    config.if = -> { recipient.telegram_chat_id.present? }
  end
end
```

Procs run in the context of the notification, so `recipient` is available too.

## Options

| Option | Required | |
|---|---|---|
| `bot_token` | yes | From @BotFather. |
| `chat_id` | yes | Numeric ID or `@channelname`. |
| `text` | | The message. Telegram rejects a send without text, so set this or put `text` in `json`. |
| `message_thread_id` | | Forum topic to post into. |
| `parse_mode` | | `"HTML"`, `"MarkdownV2"`, or `"Markdown"`. Escape user input to match. |
| `link_preview_options` | | e.g. `{ is_disabled: true }`. |
| `disable_web_page_preview` | | Older form of the above; Telegram still accepts it. |
| `disable_notification` | | `true` sends silently. |
| `protect_content` | | `true` blocks forwarding and saving. |
| `entities`, `reply_markup` | | Passed through as given. |
| `json` | | A hash merged over everything above, for any other `sendMessage` field. |
| `raise_if_not_ok` | | Defaults to `true`. Set `false` to ignore failed sends instead of raising. |

Every option accepts a value, a proc, or a symbol naming a method on the notifier, as in the rest of Noticed. Noticed's own `if`, `unless`, `wait`, and `queue` options work as usual.

## Failures

A send counts as delivered only when Telegram answers with a 2xx status **and** `"ok": true`. Anything else raises `Noticed::ResponseUnsuccessful`, with Telegram's error description in the message and the token shown as `bot[FILTERED]`. Common causes:

- `403 Forbidden: bot was blocked by the user`: the user stopped the bot. Clear their stored chat ID.
- `400 Bad Request: chat not found`: wrong ID, or the user never messaged the bot.
- `429 Too Many Requests`: Telegram's [rate limits](https://core.telegram.org/bots/faq#my-bot-is-hitting-limits-how-do-i-avoid-this). Retry with backoff:

```ruby
# config/initializers/noticed.rb
ActiveSupport.on_load(:noticed_delivery_methods_telegram) do
  retry_on Noticed::ResponseUnsuccessful, wait: :polynomially_longer, attempts: 5
end

ActiveSupport.on_load(:noticed_bulk_delivery_methods_telegram) do
  retry_on Noticed::ResponseUnsuccessful, wait: :polynomially_longer, attempts: 5
end
```

## Why a separate gem

This was [proposed to Noticed](https://github.com/excid3/noticed/pull/568). The maintainer preferred that Telegram support live in its own gem, maintained by someone who uses Telegram.

## License

MIT
