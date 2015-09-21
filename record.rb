#!/usr/bin/ruby
#ARGV[0] = Event Title
#ARGV[1] = Recording duration 
require 'logger'

# Where are we?
DIR = File.expand_path(File.dirname(__FILE__))

# Output folder for the recording
OUTPUT_DIR = "~/"

# Where is the stream?
STREAM_URL = "http://localhost:8000/listen.m3u"

# Get Today's Date
d = Time.new

# This is where we will put the crontab file we generate.
LOG_FILE = File.join(DIR, 'record.log')
logger = Logger.new LOG_FILE
logger.info "recording file #{ARGV[0]} for #{ARGV[1]} seconds"
system("streamripper #{STREAM_URL} -d #{OUTPUT_DIR} -l #{ARGV[1]} -a \"#{d.year}-#{d.month}-#{d.day}_#{d.hour}-#{d.min}-#{d.sec} - #{ARGV[0]}\" -A")