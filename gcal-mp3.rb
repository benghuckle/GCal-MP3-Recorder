#!/usr/bin/ruby

require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
require 'google/api_client/auth/storage'
require 'google/api_client/auth/storages/file_store'
require 'fileutils'

APPLICATION_NAME = 'GCal MP3 Recorder'
CLIENT_SECRETS_PATH = 'client_secret.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
														 "calendar-quickstart.json")
SCOPE = 'https://www.googleapis.com/auth/calendar.readonly'

# Get Today's Date
d = Date.today

# How many mintues to you want to record pre and post the event time
PRE_RECORD_TIME = 5
POST_RECORD_TIME = 5

# Which hour in the day would you like to check for new events? (24 hour)
PULL_HOUR = 8

# How many days in the future would you like to check for? This is just incase the script fails one day so you this have entries to record
SEARCH_RANGE = 5

# Where are we?
DIR = File.expand_path(File.dirname(__FILE__))

# This is where we will put the crontab file we generate.
TEMP_FILE = File.join(DIR, 'crontab.tmp')

# Log file info
LOG_FILE = File.join(DIR, 'gcal-mp3.log')
logger = Logger.new LOG_FILE
logger.info "Running gcal mp3 script"

#This the name of the recording script
SCRIPT_FILE = "#{DIR}/record.rb"
ENTRIES_TO_ADD = ["* #{PULL_HOUR} * * * #{DIR.gsub(/\s/,'\ ')}/gcal-mp3"]

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization request via InstalledAppFlow.
# If authorization is required, the user's default browser will be launched
# to approve the request.
#
# @return [Signet::OAuth2::Client] OAuth2 credentials
def authorize
	FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

	file_store = Google::APIClient::FileStore.new(CREDENTIALS_PATH)
	storage = Google::APIClient::Storage.new(file_store)
	auth = storage.authorize

	if auth.nil? || (auth.expired? && auth.refresh_token.nil?)
		app_info = Google::APIClient::ClientSecrets.load(CLIENT_SECRETS_PATH)
		flow = Google::APIClient::InstalledAppFlow.new({
			:client_id => app_info.client_id,
			:client_secret => app_info.client_secret,
			:scope => SCOPE})
		auth = flow.authorize(storage)
		puts "Credentials saved to #{CREDENTIALS_PATH}" unless auth.nil?
	end
	auth
end

def duration(start_time, end_time)
	return (end_time - start_time) #return the time diffence in seconds
end

# Initialize the API
client = Google::APIClient.new(:application_name => APPLICATION_NAME)
client.authorization = authorize
calendar_api = client.discovered_api('calendar', 'v3')

# Fetch the next 10 events for the user
results = client.execute!(
	:api_method => calendar_api.events.list,
	:parameters => {
		:calendarId => 'ghuckle.co.uk_7mrbjjgv3ku3b1q739ee6d8uls@group.calendar.google.com',
		:maxResults => 10,
		:singleEvents => true,
		:orderBy => 'startTime',
		:timeMin =>  Time.new(d.year, d.month, d.day).iso8601,
		:timeMax =>  Time.new(d.year, d.month, d.day+SEARCH_RANGE, 23, 59).iso8601})

if results.data.items.empty?
	#No results
	logger.error "Couldn't find any events"
else
	results.data.items.each do |event|
		#Parse the start and end dates into ruby
		if !event.start.date_time.nil? #this is to check it is not an all day event 
			event_start_date = Time.parse("#{event.start.date_time}")
			event_end_date = Time.parse("#{event.end.date_time}")
			start_date = event_start_date - PRE_RECORD_TIME*60
			end_date = event_end_date + POST_RECORD_TIME*60
			
			logger.info "Adding event #{event.summary} starting at #{start_date}"
			
			#Generate the crontab entry
			ENTRIES_TO_ADD << "#{start_date.min} #{start_date.hour} #{start_date.day} #{start_date.month} * ruby #{SCRIPT_FILE.gsub(/\s/,'\ ')} \"#{event.summary}\" #{duration(start_date, end_date)}"
		end
	end
	#Write crontab entries to the temp file
	File.open(TEMP_FILE, 'w') do |f|
		ENTRIES_TO_ADD.each { |line| f.puts line }
	end

	# Now tell crontab to load this file.
	system("crontab #{TEMP_FILE.gsub(/\s/,'\ ')}")
	logger.info "Finished gcal mp3 script "
end

