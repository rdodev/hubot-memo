# Description:
#   Leave short memos to another user. 
#   It will deliver the memos next time recipient asks for them. 
#
# Dependencies:
#   
#
# Configuration:
#   
#
# Commands:
#   wheatley memo <IRC_USER> <MESSAGE>
#   wheatley memo me
#
# Notes:
#   None 
#
# Author:
#   rdodev

storage_prefix = "MEMO_"



new_message = (sender, memo) ->
  return {from: sender, body: memo}

base_json = () ->
  return '{"messages":[]}'


module.exports = (robot) ->
  
  normalize_and_retrieve = (msg, recipient) ->
    canon_user  = msg.message.user.name.toLowerCase()
    messages    = robot.brain.get storage_prefix + (recipient ? canon_user)
    messages_js = messages or base_json()
    messages_o  = JSON.parse messages_js
    return [canon_user, messages_o]

  robot.respond /memo (\w+) (.+)/i, (msg) -> 
    recipient  = msg.match[1].trim().toLowerCase()
    memo       = msg.match[2].trim()

    if not recipient
      msg.send "Sorry, #{msg.message.user.name}, you must specify a recipient."
      msg.send "To leave a memo say <robotname> memo <recipient_IRC_handle> <memo_body>"
  
    [canon_user, messages_o] = normalize_and_retrieve msg, recipient
    messages_o.messages.push new_message(canon_user, memo)
    robot.brain.set storage_prefix + recipient, JSON.stringify messages_o


  robot.respond /memo me/i, (msg) ->
    [canon_user, messages_o] = normalize_and_retrieve msg

    if not messages_o.messages.length
      msg.send "Sorry #{canon_user}, there are no memos left for you"
      return
    for message in messages_o.messages
      msg.send "From: " + message.from + " Text: " + message.body 
    # reset after delivering
    messages_o.messages = []
    robot.brain.set storage_prefix + canon_user, JSON.stringify messages_o

  robot.enter (msg) ->
    [canon_user, messages_o] = normalize_and_retrieve msg
    if messages_o.messages and messages_o.messages.length > 0
      msg.send "#{canon_user}, you have #{messages_o.messages.length} unread memo(s)."

