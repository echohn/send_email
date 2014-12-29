#!/usr/bin/env ruby 
# encoding: utf-8

require 'send_email'

SendEmail.smtp = '192.168.12.1'
mail = SendEmail::Mail.new( :from => 'from@testmail.com' ,
        :to   => 'to@testmail.com' ,
		:cc	=> 'cc@testmail.com',
        :subject => 'Test Mail Subject',
        :msg  => "<h1>Hellow world!</h1>",
        :attachement => ARGV,
        :format => 'HTML')
mail.send
