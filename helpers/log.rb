require 'logger'

LOG = Logger.new($stdout)
LOG.datetime_format = '%Y-%m-%d %H:%M:%S'

LOG.formatter = proc do |severity, datetime, _programe, msg|
  "[#{datetime.strftime(LOG.datetime_format)}] #{severity.ljust(5)} #{msg}\n"
end
