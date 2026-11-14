# Changelog

## [Unreleased]

## [0.1.0] - 2026-11-14

- `deliver_by :telegram` and `bulk_deliver_by :telegram` for Noticed 2.x and 3.x.
- Supports forum topics (`message_thread_id`), formatting, link previews,
  silent sends, inline keyboards, and any other `sendMessage` field via `json`.
- A send counts only when Telegram returns 2xx and `"ok": true`; otherwise
  `Noticed::ResponseUnsuccessful` is raised.
- The bot token is kept out of logs and error messages.
