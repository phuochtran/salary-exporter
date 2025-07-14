require 'date'
require_relative '../helpers/http'
require_relative '../error_handlers/custom_errors/validation_error'

module PaymentsValidator
  def self.validate(company_id, payments)
    # Validate data structure
    raise ValidationError, 'Missing field company_id' unless company_id
    raise ValidationError, 'Field company_id must be a string' unless company_id.is_a?(String)
    raise ValidationError, 'Missing field payments' unless payments
    raise ValidationError, 'Field payments must be an array' unless payments.is_a?(Array)

    # Validate each payment as requirement
    payments.each do |payment|
      raise ValidationError, 'Amount must be > 0' unless payment['amount_cents'].to_i > 0
      raise ValidationError, 'BSB must be 6 digits' unless payment['bank_bsb'] =~ /^\d{6}$/
      raise ValidationError, 'Account number must be 6-9 digits' unless payment['bank_account'] =~ /^\d{6,9}$/
      raise ValidationError, 'Currency must be AUD' unless payment['currency'] == 'AUD'
      raise ValidationError, 'Pay date must be today or later' if Date.parse(payment['pay_date']) < Date.today
    end
  end
end
