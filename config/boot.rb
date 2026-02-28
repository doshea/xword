ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

# Rails 5.1.4 postgresql_adapter.rb hardcodes `gem "pg", "~> 0.18"` which
# rejects pg 1.x. Intercept that specific call and relax the constraint.
module PgGemVersionFix
  def gem(name, *requirements)
    requirements = ['>= 0.18', '< 2.0'] if name == 'pg' && requirements == ['~> 0.18']
    super(name, *requirements)
  end
end
Kernel.prepend(PgGemVersionFix)
