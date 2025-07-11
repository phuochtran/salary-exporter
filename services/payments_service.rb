require 'date'
require 'fileutils'
require_relative '../helpers/database'
require_relative '../helpers/log'

module PaymentsService
  def self.export
    export_dir = ENV['EXPORT_DIR']
    FileUtils.mkdir_p(export_dir)
    begin
      LOG.info "Exporting salary payments ..."

      # Get DB connection
      db = connect_database

      # Collect all payments need to be exported
      pending_payments = db.exec_params("SELECT * FROM payments WHERE status = 'pending' AND pay_date <= $1", [Time.now])

      # Do nothing if there is no payments need to be exported
      return LOG.info "No payments to export" if pending_payments.ntuples == 0

      file_name = "#{Time.now.strftime("%Y_%m_%d")}.txt"
      exported_file = File.expand_path(File.join(export_dir, file_name))

      File.open(exported_file, 'w') do |file|
        pending_payments.each do |payment|
          line = [payment['company_id'], payment['employee_id'], payment['bank_bsb'], payment['bank_account'], payment['amount_cents'], payment['currency'], payment['pay_date']].join(',')
          file.puts(line)
          db.exec_params("UPDATE payments SET status = 'exported', exported_time = $1, exported_file = $2 WHERE payment_id = $3", [Time.now, exported_file, payment['payment_id']])
        end
      end
      LOG.info "Successfully exported #{pending_payments.ntuples} payments to file #{file_name}"
      upload(exported_file)
    rescue => e
      LOG.error "Failed to export payments: #{e.class} - #{e.message}"
      LOG.debug e.backtrace.join("\n")
    end
  end

  def self.upload(exported_file)
    upload_dir = ENV['UPLOAD_DIR']
    FileUtils.mkdir_p(upload_dir)
    begin
      file_name = File.basename(exported_file)
      uploaded_file = File.expand_path(File.join(upload_dir, file_name))
      FileUtils.cp(exported_file, uploaded_file)
      LOG.info "Successfully uploaded file #{file_name} to bank via SFTP"
    rescue => e
      LOG.error "Failed to upload file #{file_name} to bank via SFTP"
      LOG.debug e.backtrace.join("\n")
    end
  end
end
