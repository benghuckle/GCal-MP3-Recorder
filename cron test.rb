#!/usr/bin/ruby
# cron_setup.rb
#
# This is an automated way of ensuring that entries exist in a server's
# crontab file. We want to deploy a set of cron jobs to all servers,
# and ensure that those jobs make it into the crontab file so they run
# on schedule. All of this should be done programmatically, so we don't
# have to manually log in to each machine and set up the crontab.
#
# The following entry would make the disk_check script run
# every day at 4:00 AM.
#
# 0 4 * * * ruby /var/cron/disk_check.rb
#
# Note: You can run crontab -u &lt;user&gt; -l to read the crontab file
# for a specific user, but only if you have root privileges.
# As root, you can also run crontab -u &lt;user&gt; filename to have
# crontab replace the user's cron with the file you specify.
# ---------------------------------------------------------------------------
 
# Where are we?
DIR = File.expand_path(File.dirname(__FILE__))
 
# This command reads the crontab file belonging to CRON_USER
READ_CMD  = "crontab -l"
 
# This is where we will put the crontab file we generate.
TEMP_FILE = File.join(DIR, 'crontab.tmp')
 
# This command tells crontab to load the file we specify.
WRITE_CMD = "crontab #{TEMP_FILE}"
 
# What entries do we want to force into the crontab file?
# This is an array of strings!
ENTRIES_TO_ADD = ['0 4 * * * /opt/ruby/bin/ruby /var/cron/disk_check.rb']
 
# What entries do we want to remove from the crontab file?
# This is an array of strings!
# Note that for the entry to be removed, it must exactly
# match an existing crontab entry. So watch out for extra
# spaces and capitalization.
ENTRIES_TO_REMOVE = ['0 8 * * * ruby /var/cron/blah.rb']
 
# Now get the existing crontab for the specified user.
system("#{READ_CMD}")
existing_crontab = File.open(TEMP_FILE, 'r').read
existing_lines = existing_crontab.split(/\n/) || []
existing_lines.each { |line| line.strip! }
 
# Look for each of the entries in ENTRIES. If it's not in
# the existing crontab, add it.
new_lines = existing_lines.dup
ENTRIES_TO_ADD.each do |entry|
	if !existing_lines.include?(entry)
		new_lines && entry
	end
end
 
# Remove stuff we don't want anymore.
lines_to_write = []
ENTRIES_TO_REMOVE.each do |entry|
	lines_to_write = new_lines.take_while do |line|
		!ENTRIES_TO_REMOVE.include?(line)
	end
end
 
# Write all of the old &amp; new crontab entries to the temp file.
File.open(TEMP_FILE, 'w') do |f|
	lines_to_write.each { |line| f.puts line }
end
 
# Now tell crontab to load this file.
system("#{WRITE_CMD}")