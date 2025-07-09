require 'rack'
require 'json'
require_relative './config/database'

class App
  def call(env)
    req = Rack::Request.new(env)

    # Accept POST /payments
    if req.post? && req.path == '/payments'
      handle_payment_request(req)
    else
      response(404, 'Not Found')
    end
  end

  def handle_payment_request(req)
    begin
      data = JSON.parse(req.body.read)
      company_id = data['company_id']
      payments = data['payments']

      # Basic validation
      return response(400, 'Missing company_id') unless company_id
      return response(400, 'Missing payments') unless payments.is_a?(Array)

      conn = db_connection

      payments.each do |p|
        valid, error = validate(p)
        return response(400, error) unless valid

        conn.exec_params(
          'INSERT INTO payments (company_id, employee_id, bank_bsb, bank_account, amount_cents, currency, pay_date) VALUES ($1, $2, $3, $4, $5, $6, $7)',
          [company_id, p['employee_id'], p['bank_bsb'], p['bank_account'], p['amount_cents'], p['currency'], p['pay_date']]
        )
      end
      response(201, 'Created')
    rescue => e
      response(500, e.message)
    end
  end

  def validate(p)
    return [false, 'amount_cents must be > 0'] unless p['amount_cents'].to_i > 0
    return [false, 'BSB must be 6 digits'] unless p['bank_bsb'] =~ /^\d{6}$/
    return [false, 'Account number must be 6-9 digits'] unless p['bank_account'] =~ /^\d{6,9}$/
    return [false, 'Currency must be AUD'] unless p['currency'] == 'AUD'
    return [false, 'Pay date must be today or later'] if Date.parse(p['pay_date']) < Date.today
    [true, '']
  end

  def response(status, message)
    [status, { 'content-type' => 'application/json' }, [{ message: message }.to_json]]
  end
end
