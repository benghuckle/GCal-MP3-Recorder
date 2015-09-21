# GCal-MP3-Recorder
Creates crontab recordings via streamripper based on Google Calendar events

##Install

###Git

```
sudo apt-get install git
```

###Ruby

First of all, install the prerequisite libraries:

```
sudo apt-get update
sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev
```

Then install rbenv, which is used to install Ruby:

```
cd
git clone git://github.com/sstephenson/rbenv.git .rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec $SHELL

git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
exec $SHELL

rbenv install 2.2.0
rbenv global 2.2.0
ruby -v
```

Go and make a coffee, this is going to take a while!

###Google API Gem

`gem install "google-api-client"`

###Streamripper
`sudo apt-get install streamripper`

###Download script from git

```
cd
git clone https://github.com/sqr-peg/GCal-MP3-Recorder.git
cd GCal-MP3-Recorder
```


##Setup

###Find your calendar ID

1. Visit [Google Calendar](https://www.google.com/calendar/) in your web browser.

2. In the calendar list on the left, click the down-arrow button next to the appropriate calendar, then select Calendar settings.

3. In the Calendar Address section, locate the Calendar ID listed next to the XML, ICAL and HTML buttons.

4. Copy the Calendar ID.

5. Open `gcal-mp3.rb` and change `CALENDER_ID` to your Calendar ID

###Run script for the first time

```
ruby gcal-mp3.rb
```

This will open a web browser where you have to log in to a Google account with access to the calendar.

Once complete, it will create a cron job for the script itself and any google events.

```
crontab -l
* 8 * * * /home/parallels/GCal-MP3-Recorder/gcal-mp3
55 9 21 9 * ruby /home/parallels/GCal-MP3-Recorder/record.rb "Test Event" 4200.0
```