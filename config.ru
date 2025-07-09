require 'rufus-scheduler'
require './app'
require './services/payments_service'

run App.new

scheduler = Rufus::Scheduler.new
scheduler.cron '* * * * *' do
  PaymentsService.export
end
