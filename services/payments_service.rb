require 'date'
require 'fileutils'
require_relative '../helpers/database'
require_relative '../helpers/log'

module PaymentsService
  def self.export
    exports_dir = 'exports'
    FileUtils.mkdir_p(exports_dir)
    begin
      LOG.info "Exporting salary payments ..."

      # Get DB connection
      db = connect_database

      # Collect all payments need to be exported
      pending_payments = db.exec_params("SELECT * FROM payments WHERE status = 'pending' AND pay_date <= $1", [Time.now])

      # Do nothing if there is no payments need to be exported
      return LOG.info "No payments to export" if pending_payments.ntuples == 0

      timestamp = Time.now.strftime("%Y_%m_%d")
      exported_file = "#{timestamp}.txt"
      exported_file_path = File.expand_path(File.join(exports_dir, exported_file))

      File.open(exported_file_path, 'w') do |file|
        pending_payments.each do |payment|
          line = [payment['company_id'], payment['employee_id'], payment['bank_bsb'], payment['bank_account'], payment['amount_cents'], payment['currency'], payment['pay_date']].join(',')
          file.puts(line)
          db.exec_params("UPDATE payments SET status = 'exported', exported_at = $1, exported_file = $2 WHERE payment_id = $3", [Time.now, exported_file_path, payment['payment_id']])
        end
      end
      LOG.info "Successfully exported #{pending_payments.ntuples} payments to file #{exported_file}"
      upload(exported_file_path)
    rescue => e
      LOG.error "Failed to export payments: #{e.class} - #{e.message}"
      LOG.debug e.backtrace.join("\n")
    end
  end

  def self.upload(exported_file_path)
    outbox_dir = 'outbox'
    FileUtils.mkdir_p(outbox_dir)
    begin
      exported_file = File.basename(exported_file_path)
      outbox_file_path = File.expand_path(File.join(outbox_dir, exported_file))
      FileUtils.cp(exported_file_path, outbox_file_path)
      LOG.info "Successfully uploaded file #{exported_file} to bank via SFTP"
    rescue => e
      LOG.error "Failed to upload file #{exported_file} to bank via SFTP"
      LOG.debug e.backtrace.join("\n")
    end
  end
end
