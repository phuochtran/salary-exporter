require 'json'
require_relative '../services/payments_service'
require_relative '../validators/payments_validator'
require_relative '../utils/error_handler'

module PaymentsController
  def self.create(request)
    # Extract request data
    data = JSON.parse(request.body.read)

    # Validate request data
    PaymentsValidator.validate(data['company_id'], data['payments'])

    # Create payments
    PaymentsService.create(data['company_id'], data['payments'])
    return Http.response(201, 'Successfully created payments')
  rescue => error
    ErrorHandler.handle(error)
  end
end
