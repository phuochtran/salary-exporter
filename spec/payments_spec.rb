require_relative '../app'
require 'rack/test'
require 'rspec'
require 'date'

RSpec.describe 'POST /payments' do
  include Rack::Test::Methods

  def app
    App.new
  end

  # Test data
  let(:valid_payload) do
    {
      company_id: 'com001',
      payments: [
        {
          employee_id: 'emp003',
          bank_bsb: '062000',
          bank_account: '12345678',
          amount_cents: 150000,
          currency: 'AUD',
          pay_date: Date.today.to_s
        }
      ]
    }
  end

  # Test case 1
  it 'returns 201 when valid' do
    post '/payments', valid_payload.to_json, 'Content-Type' => 'application/json'
    expect(last_response.status).to eq(201)
    expect(JSON.parse(last_response.body)['status']).to eq('SUCCESS')
  end

  # Test case 2
  it 'returns 400 when amount is invalid' do
    invalid_payload = valid_payload.dup
    invalid_payload[:payments][0][:amount_cents] = 0
    post '/payments', invalid_payload.to_json, 'Content-Type' => 'application/json'
    expect(last_response.status).to eq(400)
    expect(JSON.parse(last_response.body)['status']).to eq('ERROR')
  end

  # Test case 3
  it 'returns 400 when bsb is invalid' do
    invalid_payload = valid_payload.dup
    invalid_payload[:payments][0][:bank_bsb] = '06200'
    post '/payments', invalid_payload.to_json, 'Content-Type' => 'application/json'
    expect(last_response.status).to eq(400)
    expect(JSON.parse(last_response.body)['status']).to eq('ERROR')
  end

  # Test case 4
  it 'returns 400 when account number is invalid' do
    invalid_payload = valid_payload.dup
    invalid_payload[:payments][0][:bank_account] = '12345'
    post '/payments', invalid_payload.to_json, 'Content-Type' => 'application/json'
    expect(last_response.status).to eq(400)
    expect(JSON.parse(last_response.body)['status']).to eq('ERROR')
  end

  # Test case 5
  it 'returns 400 when currency is invalid' do
    invalid_payload = valid_payload.dup
    invalid_payload[:payments][0][:currency] = 'USD'
    post '/payments', invalid_payload.to_json, 'Content-Type' => 'application/json'
    expect(last_response.status).to eq(400)
    expect(JSON.parse(last_response.body)['status']).to eq('ERROR')
  end

  # Test case 6
  it 'returns 400 when pay date is invalid' do
    invalid_payload = valid_payload.dup
    invalid_payload[:payments][0][:pay_date] = (Date.today - 1).to_s
    post '/payments', invalid_payload.to_json, 'Content-Type' => 'application/json'
    expect(last_response.status).to eq(400)
    expect(JSON.parse(last_response.body)['status']).to eq('ERROR')
  end
end
