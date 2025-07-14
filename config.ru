require 'rufus-scheduler'
require './app'
require './services/payments_service'

run App.new

# Configure cronjob scheduling
scheduler = Rufus::Scheduler.new
export_time = ENV['EXPORT_TIME']
scheduler.cron export_time do
  PaymentsService.export
end
