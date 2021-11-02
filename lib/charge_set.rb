require "charge_set/version"
require 'money'

Money.locale_backend = :i18n
Money.default_infinite_precision = true
Money.default_currency = :usd
I18n.enforce_available_locales = false

module ChargeSet
  class Error < StandardError; end
end

require "charge_set/set"
require "charge_set/charge"
