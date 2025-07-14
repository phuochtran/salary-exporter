require 'rack'
require_relative './controllers/payments_controller'
require_relative './helpers/http'

class App
  def call(env)
    request = Rack::Request.new(env)
    LOG.info "Calling Salary Payment API: #{request.request_method} - #{request.path_info}"
    case [request.request_method, request.path_info]
    when ['POST', '/payments']
      return PaymentsController.create(request)
    else
      return Http.response(404, 'API endpoint not found')
    end
  end
end
