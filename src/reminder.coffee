# Description:
#   Hubot reminds about the subject after specified period of time
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot remind(|me) about <query> in <time> <time period> - Reminds about <query> in specified time period
#   hubot show reminders - Shows all reminders
#   hubot clear reminders - Clears all reminders
#   e.g. hubot remind about dinner after 10 minutes
#   e.g. hubot remind me about tv show after 15 seconds
#
# Author:
#   github.com/sadikovi
#

response = [
  "okay",
  "sure thing",
  "no problem",
  "roger that",
  "affirmative"
]

module.exports = (robot) ->
    reminders = []

    addReminder = (query, timeout, msg) ->
        remid = setTimeout ()->
            # reply with message
            msg.send "Reminder: #{query}"
            removeReminder(remid)
        , timeout*1000
        # add reminder to the array
        reminders.push {id: remid, query: query, from: Date.now(), timeout: timeout}

    removeReminder = (remid) ->
        clearTimeout remid
        reminders = (x for x in reminders when x.id != remid)

    clearReminders = ->
        clearTimeout x.id for x in reminders
        reminders = []

    timeLeft = (from, period) ->
        seconds = parseInt period-(Date.now()-from)/1000
        return "right now" if seconds <= 1
        return "in #{seconds} seconds" if seconds < 60
        minutes = parseInt seconds/60
        return "in #{minutes} minute(s) and #{(seconds%60+60)%60} second(s)" if minutes < 60
        # otherwise return hours and minutes
        hours = parseInt minutes/60
        return "in #{hours} hour(s) and #{(minutes%60+60)%60} minute(s)"

    robot.respond /(remind|remind me)([ ]+)(about )(.+)( in)([ ]+)([0-9]+)([ ]+)(hour|minute|second)s?/i, (msg) ->
        # get parameters
        query = msg.match[4].trim()
        timeout = parseInt(msg.match[7].trim(), 10)
        period = msg.match[9].trim()
        if period == "hour"
            timeout = timeout*60*60
        else if period == "minute"
            timeout = timeout*60
        # add reminder
        addReminder query, timeout, msg
        # display affirmative message
        msg.send msg.random response

    robot.respond /clear reminders/i, (msg) ->
        if reminders.length > 0
            clearReminders()
            msg.send msg.random response
        else
            msg.send "I don't have any reminders"

    robot.respond /show reminders/i, (msg) ->
        if reminders.length == 0
            list = "No reminders"
        else
            list = ("remind about: #{x.query} #{timeLeft x.from, x.timeout}" for x in reminders).join "\n"
        msg.send list
