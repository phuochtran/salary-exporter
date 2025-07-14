require_relative '../errors/validation_error'

module ErrorHandler
  def self.handle(error)
    LOG.error "Failed to call Salary Payment API: #{error.class} - #{error.message}"
    LOG.debug error.backtrace.join("\n")
    case error
    when ValidationError
      return Http.response(400, error.message) 
    else
      return Http.response(500, error.message) 
    end
  end
end
