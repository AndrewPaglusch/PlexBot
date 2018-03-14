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

def add_movie(imdbid)
  results = api_query_movie("movie.add?identifier=#{imdbid}&profile_id=#{@cp_profile_id}")
  j_results = JSON.parse(results, :symbolize_names => true)
  if j_results[:success] == true
    return true, j_results[:movie][:title], j_results[:movie][:info][:images][:poster][0], nil 
  else
    puts "Failure adding movie! IMDBID: #{imdbid}. Dumping response object..."
    pp j_results
    #the json failure message doesn't have the movie name (like the success json does)
    #so we need to look it up via the imdbid. This may also fail if there's an issue with CP
    return false, movie_imdbid_to_title(imdbid), nil, nil
  end
end

def search_movie_local(imdb)
  results = JSON.parse(api_query_movie("media.get/?id=#{imdb}"), :symbolize_names => true)

  if ! results[:media].nil?
    return true #movie found
  else
    return false #movie not found
  end
end

def get_movie_profile_list
  results = JSON.parse(api_query_movie("profile.list"))
  profiles = Array.new

  results["list"].each {|r| profiles.insert(-1, { "name" => r["label"], "profile_id" => r["_id"]})}

  # [ {"1080p" => "z9y8x7w6v5u4..."}, {"720p" => "a1b2c3d4e5..."} ]
  return profiles
end


def api_query_movie(query)
  url = URI.parse("#{@movie_url}:#{@movie_port}#{@movie_context}/api/#{@movie_api_key}/#{URI.escape(query)}")

  request = Net::HTTP.new(url.host, url.port)

  #Set timeout and scheme
  request.use_ssl = url.scheme == 'https'
  request.read_timeout = @movie_timeout
  request.open_timeout = @movie_timeout

  begin
    #Make the request
    response = request.start {|req| req.get(url) }
  rescue
    raise $!.message
  end

  return response.body
end
