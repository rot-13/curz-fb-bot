class AppServerClient
  include HTTParty
  base_uri 'https://cpc-curz.herokuapp.com'
  debug_output $stdout

  def play_url(url)
    self.class.post('/play_url', body: {url: url})
  end

  def save_url(url, title)
    self.class.post('/save_url', body: {url: url, title: title})
  end

end