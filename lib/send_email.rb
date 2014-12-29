require 'net/smtp'
require "send_email/version"
# vim: nu ts=4
module SendEmail
  # Your code goes here...
	@smtp = '127.0.0.1'
	EOL = "\r\n"
	
	class << self
		attr_accessor :smtp
		def mail_to(from,to,subject,msg,format = 'txt')
			mail_info = Hash.new
			mail_info[:from] = from
			mail_info[:to]	 = to
			mail_info[:subject] = subject
			mail_info[:msg] 	= msg
			mail_info[:format]	= format
			Mail.new(mail_info).send
		end
	end

	class Mail
		Marker = "AUNIQUEMARKER"

		def initialize(mail_info)
			@mail_info = mail_info
			@from 	= @mail_info[:from]
			@to   	= @mail_info[:to]
			@subject= @mail_info[:subject]
			@msg	= @mail_info[:msg]
			@cc		= @mail_info[:cc]
			@bcc	= @mail_info[:bcc]
			@format = @mail_info[:format] || 'txt'
			@attachement = @mail_info[:attachement]
			
			@to  = modify_type @to
			@cc  = modify_type @cc
			@bcc = modify_type @bcc
			
			subject_encode

			if have_attachement?
				attachement_read
				attachement_encode
				attachement_body
			end
		end

		def modify_type(x)
				x.split(",") if x.class == String
		end

		def send
			Net::SMTP.start(SendEmail.smtp) do |smtp|
				smtp.send_mail(mail_header + EOL + @msg,@from,[@to,@cc,@bcc].compact)
			end
		end
		private
 
		def subject_encode
 			@subject = "=?UTF-8?B?" + [@subject].pack("m").chomp + "?="
 		end

		def header 
			header = "To: #{@to.join(",")}" + EOL + 
			"From: #{@from}" + EOL + 
			"Subject: #{@subject}" + EOL
			header += "cc: #{@cc.join(",")}"  + EOL if @cc
			header
		end

		def txt_header
			"MIME-Version: 1.0" + EOL +
			"Content-type: text/plain" + EOL +
			"Content-Transfer-Encoding:8bit" + EOL
		end

		def html_header
			"MIME-Version: 1.0" + EOL +
			"Content-type: text/html" + EOL +
			"Content-Transfer-Encoding:8bit" + EOL
		end

		def attachement_header
			"MIME-Version: 1.0" + EOL +
			"Content-type: multipart/mixed; boundary=#{Marker}" + EOL +
			"--#{Marker}" + EOL	
		end	

		def have_attachement?
			!@attachement.nil?
		end
		
		def mail_header
			mail_header = have_attachement? ? header + attachement_header : header
			mail_header += @format.upcase == 'HTML' ? html_header  : txt_header 
			mail_header
		end

		def attachement_read
			@attachement_content = []
			@attachement_basename = []
			@attachement.each do |file_name|
				@attachement_content << File.read(file_name)
				@attachement_basename << File.basename(file_name)
			end
		end
		
		def attachement_encode
			@attachement_encode = []
			@attachement_content.each do |file|
				@attachement_encode << [file].pack("m") 
			end
		end

		def attachement_body
			@msg += EOL + "--#{Marker}" + EOL 
			@attachement.each_index do |i|
				@msg += "Content-type: multipart/mixed; name=\"#{@attachement_basename[i]}\"" + EOL +
				"Content-Transfer-Encoding:base64" + EOL +
				"Content-Disposition: attachement; filename=#{@attachement_basename[i]}" + EOL + EOL +
				"#{@attachement_encode[i]}" + EOL +
				"--#{Marker}--" + EOL
			end
		end



	end
end
