def search_show(title)
  
  def search_movie(title)
    query = "movie.search?q=#{title}"
    results = JSON.parse(api_query_movie(query), :symbolize_names => true)
   
    #movies = multiple results
    #movie = one result
    if ! results[:movie].nil? then
      results[:movies] = results[:movie]
    end
  
    return if results[:movies] == nil
    
    movies = Array.new
  
    results[:movies].each do |r|
      if ! r[:imdb].nil?
        movies.insert(-1, { :imdbid => r[:imdb], :title => r[:titles][0], :year => r[:year], :requested => r[:in_wanted], :downloaded => r[:in_library]})
      end
    end
  
    return if movies.count == 0
  
    return movies
  end
  
  def movie_imdbid_to_title(imdbid)
    movie = search_movie("#{imdbid}")
    return movie[0][:title]
  end

def add_show(imdbid)
  #Search for this show via imdbid to get it as the only result
  #Sonarr needs the JSON from the result as the submission to actually download the show
  search_results = JSON.parse(api_query("movie/lookup", "term=tvdb:#{imdbid}"))[0]

  #Copy over only the objects that Sonarr requires from the search result JSON 
  search_json = Hash.new
  search_json['imdbId'] = search_results['imdbid']
  search_json['title'] = search_results['title']
  search_json['qualityProfileId'] = search_results['qualityProfileId']
  search_json['titleSlug'] = search_results['titleSlug']
  search_json['images'] = search_results['images']
  search_json['rootFolderPath'] = JSON.parse(api_query("rootfolder", ""))[0]['path']
  search_json['profileId'] = @sonarr_profile_id

  #Get album art from search_results
  album_art_url = search_results['remotePoster']

  #POST the 'search_json.to_json' text to Sonarr to start the download
  add_results = JSON.parse(api_query('movie', '', search_json.to_json))

  #success message is a hash {}. errors are an array [] of hashes {}
  #extract the hash at index 0 of error array so that it's just a hash
  if add_results.is_a? Array then
    add_results = add_results[0]
  end

  if add_results['imdbid'].to_s == imdbid
    return true, add_results['title'], album_art_url
  else
    puts "Failure adding show! imdbid: #{imdbid}. Dumping response object..."
    pp add_results
    return false, search_results['title'], nil, add_results['errorMessage']
  end
end

def get_show_profile_list
  endpoint = "profile"

  results = JSON.parse(api_query(endpoint, ""))
  profiles = Array.new

  results.each {|r| profiles.insert(-1, { "name" => r["name"], "profile_id" => r["id"]})}

  # [ {"1080p" => "z9y8x7w6v5u4..."}, {"720p" => "a1b2c3d4e5..."} ]
  return profiles
end

def search_show_local(imdbid)
  JSON.parse(api_query("movie", ""), :symbolize_names => true).each do |show|
    return true if show[:imdbid] == imdbid
  end
  return false
end

def api_query(endpoint, query, postdata = "")
  url = URI.parse("#{@sonarr_url}:#{@sonarr_port}#{@sonarr_context}/api/#{endpoint}?#{URI.escape(query)}&apikey=#{@sonarr_api_key}")

  if postdata == "" then
    #Request being made without POST data
    request = Net::HTTP.new(url.host, url.port)
    request.use_ssl = url.scheme == 'https'
    request.read_timeout = @sonarr_timeout
    request.open_timeout = @sonarr_timeout
  
    begin
      #Make the request
      response = request.start {|req| req.get(url) }
    rescue
      raise $!.message
    end
  
    return response.body
  else
    #Request being made via POST
    request = Net::HTTP::Post.new(url)
    request.body = postdata
    #request.read_timeout = @sonarr_timeout
    #request.open_timeout = @sonarr_timeout
    
    #Make the request    
    begin
      response = Net::HTTP.start(url.hostname, url.port) do |http|
        http.request(request)
      end
    rescue
      raise $!.message
    end

    return response.body
  end
end
