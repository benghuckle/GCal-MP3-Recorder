#!/usr/bin/ruby

require 'net/http'
require 'rexml/document'

url = 'https://www.google.com/calendar/feeds/ghuckle.co.uk_7mrbjjgv3ku3b1q739ee6d8uls%40group.calendar.google.com/public/basic'

# get all future events, ordered by start time
url = url + "?start-min=2015-09-20T00:00:00&start-max=2015-09-20T23:59:59&orderby=starttime"

xml_data = Net::HTTP.get_response(URI.parse(url)).body
doc = REXML::Document.new( xml_data )

titles = []
content = []
doc.elements.each('feed/entry/title'){ |e| titles << e.text }
doc.elements.each('feed/entry/content'){ |e| content << e.text }

#print all events
titles.each_with_index do |title, idx|
	puts "Title: " + title + "\n\n"
	puts content[idx]
	puts "\n----\n\n"
end