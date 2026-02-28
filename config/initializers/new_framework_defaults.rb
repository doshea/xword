# Be sure to restart your server when you modify this file.
#
# This file contains migration options to ease your Rails 5.0 upgrade.
# Once upgraded flip defaults one by one to migrate to the new default.
# Read the Rails 5.0 release notes for more info on each option.

# Enable per-form CSRF tokens. Flipped to true (Rails 5.0+ default).
Rails.application.config.action_controller.per_form_csrf_tokens = true

# Enable origin-checking CSRF mitigation. Flipped to true (Rails 5.0+ default).
Rails.application.config.action_controller.forgery_protection_origin_check = true

# Make Ruby 2.4+ preserve the timezone of the receiver when calling `to_time`.
# Flipped to true (Rails 5.0+ default).
ActiveSupport.to_time_preserves_timezone = true

# Require `belongs_to` associations by default.
# Require `belongs_to` associations by default (Rails 5.2+ default).
# optional: true added to all associations with nullable FK columns.
Rails.application.config.active_record.belongs_to_required_by_default = true

# Do not halt callback chains when a callback returns false (Rails 5.1+ default).
# Callbacks must use throw(:abort) to halt. Audited: no callbacks return false.
ActiveSupport.halt_callback_chains_on_return_false = false
