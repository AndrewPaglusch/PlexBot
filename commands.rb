def process_command_m(message)

  movie_name = message.text.split(message.text.split(" ")[0] + " ")[1]

  if movie_name.nil?
    send_message(message.chat.id, "#{message.from.username}You forgot to specify the movie")
    return
  end

  results = search_movie(movie_name) #Get array of :imdbid,:title,:year
  if results == nil
    send_message(message.chat.id, "#{message.from.username}No results found. Try harder")
  else
    options = [ ]
    results.each do |m|
      button_text = "#{m[:title]} (#{m[:year]})"
      
      if m[:downloaded] != false then
        button_text = "** " + button_text
      elsif m[:requested] != false then
        button_text = "* " + button_text
      end

      options.insert(-1, Telegram::Bot::Types::InlineKeyboardButton.new(text: button_text, callback_data: "DLM|#{m[:imdbid]}"))
    end

    message_text = "#{message.from.username}What movie(s) would you like?\n\n"
    message_text += "Movies prepended with '*' have already been requested\n"
    message_text += "Movies prepended with '**' have already been downloaded\n"

    send_question(message.chat.id, message_text, options)
  end
end

def process_command_s(message)
  show_name = message.text.split(message.text.split(" ")[0] + " ")[1]

  if show_name.nil?
    send_message(message.chat.id, "#{message.from.username}You forgot to specify the show")
    return
  end

  results = search_show(show_name) #Get array of :imdbid,:title,:year
  if results == nil
    send_message(message.chat.id, "#{message.from.username}No results found. Try harder")
  else
    options = [ ]
    results.each do |s|
      button_text = "#{s[:title]} (#{s[:year]}) - #{s[:season_count]} Seasons"
      button_text = "#{s[:title]} (#{s[:year]}) - #{s[:season_count]} Season" if s[:season_count] == 1

      # prepend a '-' if the show has ended
      button_text = "- " + button_text if s[:status] == "ended"

      callback_data = "DLS|#{s[:tvdbid]}"
      
      if s[:downloaded] == true then
        button_text = "* " + button_text
        #temp - disable this callback button
        #havn't added a force-redownload option yet
        callback_data = "##{callback_data}"	
      else
        #only check this if it's not downloaded yet
        if s[:season_count] > @season_admin_cutoff
          button_text = "+ #{button_text}"
          callback_data = "!#{callback_data}"
        end
      end
      options.insert(-1, Telegram::Bot::Types::InlineKeyboardButton.new(text: button_text, callback_data: callback_data))
    end

    message_text = "#{message.from.username}What show(s) would you like?\n\n"
    message_text += "Shows prepended with '+' will need to be downloaded by an admin due to their size\n"
    message_text += "Shows prepended with '-' are no longer a continuing series.\n"
    message_text += "Ask @#{@admin_username} to approve these items.\n\n"
    message_text += "Shows prepended with '*' have already been requested\n"
    send_question(message.chat.id, message_text, options)
  end
end


def process_command_a(message)

  if ! message_from_admin?(message)
    send_message(message.chat.id, File.read('static_messages/not-admin.txt'))
    return
  end

  command = message.text.split(message.text.split(" ")[0] + " ")[1]

  if command.nil? 
    send_message(message.chat.id, "#{message.from.username}You forgot to specify the admin command")
    return
  end

  #Make sure the script exists
  if ! File.file?("scripts/#{command}.sh")
    send_message(message.chat.id, "#{message.from.username}Not a valid command!")
    return
  end

  begin
    results = `scripts/#{command}.sh`
  rescue
    send_message(message.chat.id, "#{message.from.username}Command resulted in an error. Refer to console")
    puts $!.message
    return
  end

  if results == nil || results == ""
    send_message(message.chat.id, "#{message.from.username}No output returned from admin command")
  else
    send_message_markdown(message.chat.id, results.chomp)
  end

end
