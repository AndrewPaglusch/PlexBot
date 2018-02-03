def process_callback_dlm(message)
  imdbid = message.data.split("|")[1]

  #DLM | IMDB_ID
  if search_movie_local(imdbid) == true
    #This movie's already in CouchPotato. Force re-download?
    #Keep in mind that the user has already been shown that we have this movie already via the "*" prefix on the button
    options = [ ]
    options.insert(-1, Telegram::Bot::Types::InlineKeyboardButton.new(text: "Yes", callback_data: "RDLM|#{imdbid}"))
    options.insert(-1, Telegram::Bot::Types::InlineKeyboardButton.new(text: "No", callback_data: "NRDLM|"))
    row = [options]
    send_question(message.message.chat.id, "#{message.from.username}#{File.read('static_messages/force-redownload.txt')}", row) 
  else
    success, moviename, imdbpic, opt_msg = add_movie(imdbid)
    if success == true
      send_message(message.message.chat.id, "#{message.from.username}'#{moviename}' has been queued for download.", imdbpic)
    else
      if opt_msg.nil? then
        send_message(message.message.chat.id, "#{message.from.username}'#{moviename}' FAILED to be queued for download.\n\nAsk #{@admin_name} (@#{@admin_username}) for assistance.")
      else
        send_message(message.message.chat.id, "#{message.from.username}'#{moviename}' FAILED to be queued for download.\n\nError: #{opt_msg}\n\nAsk #{@admin_name} (@#{@admin_username}) for assistance.")
      end
    end
  end #if
end

def process_callback_dls(message)
  tvdbid = message.data.split("|")[1]

  #TODO Like movies, search the local shows first. If we already have
  #the show that they just requested, ask them if they need it to be re-downloaded or something
  #keep in mind that the user has **already been shown** ("*" prefix) if we do/don't have the show before this method is called

  success, showname, showpic, opt_msg = add_show(tvdbid)
  if success == true
    send_message(message.message.chat.id, "#{message.from.username}'#{showname}' has been queued for download.", showpic)
  else
    if opt_msg.nil? then
      send_message(message.message.chat.id, "#{message.from.username}'#{showname}' FAILED to be queued for download.\n\nAsk #{@admin_name} (@#{@admin_username}) for assistance.")
    else
      send_message(message.message.chat.id, "#{message.from.username}'#{showname}' FAILED to be queued for download.\n\nError: #{opt_msg}\n\nAsk #{@admin_name} (@#{@admin_username}) for assistance.")
    end
  end
end

def process_callback_rdlm(message)
  imdbid = message.data.split("|")[1]

  #Skip searching local movies. We're forcing a re-download
  success, moviename, imdbpic = add_movie(imdbid)
  if success == true
    send_message(message.message.chat.id, "#{message.from.username}'#{moviename}' has been queued for a forced re-download.", imdbpic)
  else
    send_message(message.message.chat.id, "#{message.from.username}'#{moviename}' FAILED to be queued for a forced re-download.\nAsk #{@admin_name} (@#{@admin_username}) for assistance.")
  end      
end

def process_callback_nrdlm(message)
  send_message(message.message.chat.id, "#{message.from.username}This movie will NOT be re-downloaded.")
end

