class AppServerClient
  include HTTParty
  base_uri 'http://192.168.2.37:5000'
  debug_output $stdout

  def play_url(url)
    self.class.post('/play_url', body: {url: url})
  end

end