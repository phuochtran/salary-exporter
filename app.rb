require_relative './controllers/payments_controller'

class App
  def call(env)
    req = Rack::Request.new(env)
    case [req.request_method, req.path_info]
    when ['POST', '/payments']
      PaymentsController.create(req)
    else
      PaymentsController.response(404, 'Not found')
    end
  end
end
