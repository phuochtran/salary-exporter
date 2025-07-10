require 'rack'
require 'json'
require 'date'
require_relative '../helpers/database'
require_relative '../helpers/log'

module PaymentsController
  def self.create(req)
    data = JSON.parse(req.body.read)
    company_id = data['company_id']
    payments = data['payments']

    return response(400, 'Missing company_id') unless company_id
    return response(400, 'Missing payments') unless payments.is_a?(Array)

    db = connect_database

    payments.each do |p|
      valid, error_message = validate(p)
      return response(400, error_message) unless valid

      db.exec_params(
        'INSERT INTO payments (company_id, employee_id, bank_bsb, bank_account, amount_cents, currency, pay_date) VALUES ($1, $2, $3, $4, $5, $6, $7)',
        [company_id, p['employee_id'], p['bank_bsb'], p['bank_account'], p['amount_cents'], p['currency'], p['pay_date']]
      )
    end
    response(201, 'Successfully created payments')
  rescue => e
    response(500, e.message)
  end

  def self.validate(p)
    return [false, 'Amount must be > 0'] unless p['amount_cents'].to_i > 0
    return [false, 'BSB must be 6 digits'] unless p['bank_bsb'] =~ /^\d{6}$/
    return [false, 'Account number must be 6-9 digits'] unless p['bank_account'] =~ /^\d{6,9}$/
    return [false, 'Currency must be AUD'] unless p['currency'] == 'AUD'
    return [false, 'Pay date must be today or later'] if Date.parse(p['pay_date']) < Date.today
    [true, '']
  end

  def self.response(status_code, message)
    body = {
      status: status_code.to_i >= 200 && status_code.to_i < 300 ? 'SUCCESS' : 'ERROR',
      details: {
        message: message
      }
    }
    if body[:status] == 'SUCCESS'
      LOG.info message
    else
      LOG.error message
    end
    [status_code, { 'content-type' => 'application/json' }, [body.to_json]]
  end
end
