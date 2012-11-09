#!/usr/bin/env ruby

require 'net/imap'
#require File.join(File.dirname(__FILE__), '../client/client.rb')

require 'bundler/setup'
Bundler.require(:default)

if ARGV.length < 3
  puts "Usage: #{$0} <user> <password> <host>"
  exit 1
end
(user, password, host) = ARGV
port = 993
#search = ["SINCE", "03-Nov-2012", "NOT", "DELETED", "HEADER", "SENDER", 'hydra-tech@googlegroups.com']
search = ["NOT", "DELETED", "SUBJECT", "TEST", "FROM", "Justin"]

imap = Net::IMAP.new(host, port, true)
#imap.authenticate('LOGIN', user, password)
imap.login(user, password)
imap.examine('INBOX')
imap.search(search).each do |message_id|
  msg = imap.fetch(message_id, ["ENVELOPE", "RFC822"])[0]
  envelope = msg.attr["ENVELOPE"]
  puts "#{envelope.message_id}\n"
  #puts "\t#{envelope.from[0].name}: \t#{envelope.subject}"
  msg = msg.attr["RFC822"]
  mail = Mail.read_from_string msg

  puts mail.subject
  puts mail.text_part.body.to_s
  puts mail.html_part.body.to_s
  mail.attachments.each do | attachment |
    filename = attachment.filename
  
    puts "Attachment #{filename}"
    begin
      File.open('/tmp/' + filename, "w+b", 0644) {|f| f.write attachment.body.decoded}
    rescue Exception => e
      puts "Unable to save data for #{filename} because #{e.message}"
    end
  end
end
