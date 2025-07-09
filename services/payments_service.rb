require 'date'
require 'fileutils'
require_relative '../helpers/database'
require_relative '../helpers/log'

module PaymentsService
  def self.export
    begin
      LOG.info "Starting export salary payments ..."
      db = connect_database
      payments = db.exec_params("SELECT * FROM payments WHERE status = 'pending' AND pay_date <= $1", [Time.now])
      return LOG.info "No payments to export" if payments.ntuples == 0

      timestamp = Time.now.strftime("%Y_%m_%d")
      file_name = "#{timestamp}.txt"
      export_path = File.expand_path(File.join("export", file_name))

      File.open(export_path, 'w') do |file|
        payments.each do |p|
          line = [p['company_id'], p['employee_id'], p['bank_bsb'], p['bank_account'], p['amount_cents'], p['currency'], p['pay_date']].join(',')
          file.puts(line)
          db.exec_params("UPDATE payments SET status = 'exported', exported_at = $1, export_file = $2 WHERE payment_id = $3", [Time.now, export_path, p['payment_id']])
        end
      end
      LOG.info "Successfully exported #{payments.ntuples} payments to file #{export_path}"
      upload(export_path, file_name)
    rescue => e
      LOG.error "Failed to export payments: #{e.class} - #{e.message}"
      LOG.debug e.backtrace.join("\n")
    end
  end

  def self.upload(export_path, file_name)
    begin
      outbox_path = File.expand_path(File.join("outbox", file_name))
      FileUtils.mv(export_path, outbox_path)
      LOG.info "Successfully uploaded file #{export_path} to bank via SFTP"
    rescue => e
      LOG.error "Failed to upload file #{export_path} to bank via SFTP"
      LOG.debug e.backtrace.join("\n")
    end
  end
end
