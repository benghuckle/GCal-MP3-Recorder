#!/usr/bin/ruby
require 'logger'
# Where are we?
DIR = File.expand_path(File.dirname(__FILE__))

# This is where we will put the crontab file we generate.
LOG_FILE = File.join(DIR, 'debug.log')
puts "#{LOG_FILE}"
logger = Logger.new LOG_FILE
logger.debug "recording file #{ARGV[0]} for #{ARGV[1]} minutes"