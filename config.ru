require 'rufus-scheduler'
require './app'
require './services/payments_service'

run App.new

# Configure cronjob scheduling
scheduler = Rufus::Scheduler.new
scheduler.cron '0 17 * * *' do
  PaymentsService.export
end
