#!/usr/bin/ruby
#ARGV[0] = Event Title
#ARGV[1] = Recording duration 
require 'logger'

# Where are we?
DIR = File.expand_path(File.dirname(__FILE__))
# Output folder for the recording
OUTPUT_DIR = "~/Music"

# This is where we will put the crontab file we generate.
LOG_FILE = File.join(DIR, 'record.log')
logger = Logger.new LOG_FILE
logger.info "recording file #{ARGV[0]} for #{ARGV[1]} seconds"
system("streamripper http://10.0.2.240:8000/listen.m3u -d #{OUTPUT_DIR} -l #{ARGV[1]} -a \"#{ARGV[0]}\" -A")