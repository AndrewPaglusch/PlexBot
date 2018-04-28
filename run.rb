#!/usr/bin/env ruby

require 'telegram/bot'
require 'net/http'
require 'pp'

#sanity check before starting
fail_msg = String.new
fail_msg << "settings.rb is missing\n" if File.exist?('./settings.rb') == false
fail_msg << "scripts directory is missing\n" if File.exist?('./scripts') == false
fail_msg << "static_messages directory is missing\n" if File.exist?('./static_messages') == false
abort("#{fail_msg}Aborting...") if ! fail_msg.empty?

require_relative 'settings.rb' #Settings

if @movie_source == "couchpotato"
  require_relative 'api_couchpotato.rb' #CouchPotato API
elsif @movie_source == "radarr"
  require_relative 'api_radarr.rb' #Radarr API
else
  fail_msg << "movie_source is not specified or incorrect\n"
  abort("#{fail_msg}Aborting...") if ! fail_msg.empty?
end

require_relative 'api_sonarr.rb' #Sonarr API
require_relative 'commands.rb' #/X Telegram command methods
require_relative 'callbacks.rb' #Telegram callback methods

def ack_callback(message, display_message = true)
  #Delete message and notify user that we got the request
  begin
    Telegram::Bot::Client.run(@token) do |bot|
      #bot.api.editMessageReplyMarkup(chat_id:message.message.chat.id, message_id: message.message.message_id, reply_markup: "") #Removes buttons
      if display_message == true
        bot.api.editMessageText(chat_id:message.message.chat.id, message_id: message.message.message_id, text: "#{message.from.username}Request received. Please wait...", reply_markup: "") #Removes buttons. Changes text
        bot.api.answerCallbackQuery(callback_query_id: message.id, show_alert: false, text: "Request received. Please wait...") #Sends a notification
      else
        bot.api.deleteMessage(chat_id:message.message.chat.id, message_id: message.message.message_id) #Deletes message and buttons
      end
      #bot.api.deleteMessage(chat_id:message.message.chat.id, message_id: message.message.message_id) #Deletes message and buttons
    end
  rescue
    puts "Error handling callback query. Error: " + $!.message
  end
end

def message_from_admin?(message)
  return @admin_userids.include? message.from.id.to_s
end

def handle_callback_query(message)
  #callbacks that start with a "!" ("!DMS|tt123456") can ONLY be submitted
  #by an admin. Ignore if normal user presses
  
  #Get "DLM" from "DLM|abc123"
  command = message.data.split("|")[0].upcase

  if command.start_with?('!') then
    #verify an admin pressed this button
    if ! message_from_admin?(message)
      Telegram::Bot::Client.run(@token) {|bot| bot.api.answerCallbackQuery(callback_query_id: message.id, show_alert: false, text: "Requires admin approval")}
      return
    end
    command = command.split("!")[1]
  elsif command.start_with?('#') then
    #is this an ignored command
    return
  end

  case command
    when "DLM" #download movie
      ack_callback(message)
      process_callback_dlm(message)
    when "DLS" #download show
      ack_callback(message)
      process_callback_dls(message)
    when "RDLM" #force re-download movie
      ack_callback(message) #maybe add ",false"??
      process_callback_rdlm(message)
    when "NRDLM" #don't re-download movie
      ack_callback(message, false)
      process_callback_nrdlm(message)
  end
rescue => e
  handle_exception(e, message, true)
end

def handle_user_join(message)
  message.new_chat_members.each do |i|
    if ! i.username.nil?
      #Greet by username
      send_message(message.chat.id, "@#{i.username} Welcome to the group!\n\n#{File.read('static_messages/welcome-message.txt')}")
    elsif ! i.first_name.nil?
      #Greet by first name
      send_message(message.chat.id, "Welcome to the group, #{i.first_name}!\n\n#{File.read('static_messages/welcome-message.txt')}")
    else
      #They have no username or first name. Generic greeting
      send_message(message.chat.id, "Welcome to the group!\n\n#{File.read('static_messages/welcome-message.txt')}")
    end
  end
end

def handle_message(message)
  #message#text will be nil if there was no message sent, but something still happened in the group
  #For example: A user left/joined the group, the group name changed, etc

  if ! message.reply_to_message.nil? then
    #drop message. Someone's replying to a message
    #send by our bot
    return
  end

  if message.text.nil?
    # Find out if user(s) joined the group. If so, welcome them
    if ! message.new_chat_members.nil?
      handle_user_join(message)
    else
      #Handle non-messages and non-joins here
    end
    return #so that we don't try to process this as a command (below)
  end

  case message.text.split(" ")[0].split("@")[0].downcase #Get "/m" from "/m movie name" or "/m@botname movie name"
    when "/m", "/movie" #Movie download request - "/m Movie Name"
      process_command_m(message)
    when "/s", "/show" #Show download request - "/s Show Name"
      process_command_s(message)
    when "/a", "/admin" #User is sending an admin-only command
      process_command_a(message)
    when "/help" #Show command syntax
      send_message(message.chat.id, File.read('static_messages/help.txt'))
    when "/welcome" #show welcome instructions
      send_message(message.chat.id, File.read('static_messages/welcome-message.txt'))
    else #Response not a command
      send_message(message.chat.id, "'#{message.text}' is not a valid command.\nSend '/help' for instructions")
  end
rescue => e
  handle_exception(e, message, true)
end

def handle_exception(e, message, notify_users)
  puts "=" * 60
  puts "EXCEPTION HIT!"
  puts "=" * 60
  puts "PRINTING INSPECT..."
  puts e.inspect
  puts "=" * 30
  puts "PRINTING BACKTRACE..."
  puts e.backtrace
  puts "=" * 60

  if notify_users == true then
    #is this a callback query or a message
    case message
      when Telegram::Bot::Types::Message
        send_message(message.chat.id, "The bot has run into an issue while processing a request.\n\nAsk #{@admin_name} (@#{@admin_username}) for assistance.")
      when Telegram::Bot::Types::CallbackQuery
        send_message(message.message.chat.id, "The bot has run into an issue while processing a request.\n\nAsk #{@admin_name} (@#{@admin_username}) for assistance.")
      end
  end
end

def send_message(chatid, message_text, imageurl = nil)
  if imageurl != nil
    #Send message with text as html link to image
    Telegram::Bot::Client.run(@token) {|bot| bot.api.send_message(chat_id: chatid, text: "#{message_text}<a href=\"#{imageurl}\">.</a>", parse_mode: "HTML") }
  else
    #Send a plain-text message
    Telegram::Bot::Client.run(@token) {|bot| bot.api.send_message(chat_id: chatid, text: message_text) }
  end
end

def send_message_markdown(chatid, message_text)
  #Send a plain-text message
  Telegram::Bot::Client.run(@token) {|bot| bot.api.send_message(chat_id: chatid, text: "```#{message_text}```", parse_mode: 'Markdown') }
end

def send_question(chatid, question_text, answers = [ ])
  if ! answers.empty? then
    begin
      keyboard = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: answers)
      Telegram::Bot::Client.run(@token) {|bot| bot.api.send_message(chat_id: chatid, text: question_text, reply_markup: keyboard) }
    rescue
      puts "ERROR: " + $!.message
    end
  else
    puts "send_question called without any possible answers provided"
  end
end

def validate_incoming_data(message)
  message = message.message if message.is_a? Telegram::Bot::Types::CallbackQuery
  return "Received message is not from a valid source! Type: \"#{message.chat.type}\". Ignoring." if ! @allowed_sources.include?(message.chat.type) 
  return "Unauthorized user sent message. User ID: #{message.from.id} Source ID: #{message.chat.id}." if ! @authorized_chatids.include?(message.chat.id.to_s)
  return true
end

#DEBUG
#puts get_show_profile_list
#puts get_movie_profile_list
#puts get_rootfolderpath
#puts movie_imdbid_to_title("tt0499549")
#abort

#Disabled output buffering so that
#systemd can see our stdout messages in realtime
STDOUT.sync = true

#Main loop - listen for new messages
Telegram::Bot::Client.run(@token) do |bot|
  bot.listen do |message|

    validation = validate_incoming_data(message)

    if validation == true then
      #Change message.from.username to something we can call the user
      #This makes referring to the user in replies much easier
      #@Username or their first name
      if ! message.from.username.nil? #Username -> @Username
        message.from.username = "@" + message.from.username + " "
      elsif ! message.from.first_name.nil? #Username -> John
        message.from.username = message.from.first_name + ", "
      end

      case message
        when Telegram::Bot::Types::Message
          handle_message(message) #entrypoint for all messages
        when Telegram::Bot::Types::CallbackQuery
          handle_callback_query(message) #entrypoint for all callback queries
        end
    else
      puts validation
    end

  end
end
