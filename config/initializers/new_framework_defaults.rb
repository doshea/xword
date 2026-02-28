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
# TODO Phase 2: flip to true once the test suite validates no optional belongs_to
# associations are broken. Rails 7 enforces this.
Rails.application.config.active_record.belongs_to_required_by_default = false

# Do not halt callback chains when a callback returns false.
# TODO Phase 2: flip to false (new behaviour) after auditing callbacks for
# intentional `return false` halts. Rails 5.1+ behaviour is false.
ActiveSupport.halt_callback_chains_on_return_false = true
