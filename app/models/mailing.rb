# encoding: utf-8
require 'bundler/setup'
require 'padrino-core'
require 'padrino-mailer'
require 'fileutils'

class Mailing < Padrino::Application
  register Padrino::Mailer
  def self.send_emails(filetxt, subject, body)
    emails = File.read(filetxt).split("\r\n")
    filesender = File.join(Padrino.root, "public", "sender.txt")
    emails.each do |line|
      p [Time.now, "SENDING email", line]
      arr = line.strip.split("|")
      email do
        content_type :html
        from "Rozario <no-reply@#{CURRENT_DOMAIN}>"
        to arr[0]
        subject subject
        body body.sub("#otpis#", "<a href=\"#{arr[1]}\" target=\"_blank\">Отписаться от рассылки</a>")
        via :sendmail
      end
      File.open(filesender, 'w') { |file| file.write("#{Time.now} отправлено письмо на #{arr[0]}") }
      sleep 3
    end
    File.open(filesender, 'w') { |file| file.write("#{Time.now} Рассылка успешно завершена") }
    FileUtils.rm filetxt
  end
end
