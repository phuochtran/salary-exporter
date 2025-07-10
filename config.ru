require 'rufus-scheduler'
require './app'
require './services/payments_service'

run App.new

scheduler = Rufus::Scheduler.new
scheduler.cron '0 17 * * *' do
  PaymentsService.export
end
