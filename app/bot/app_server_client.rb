class AppServerClient
  include HTTParty
  base_uri 'https://cpc-curz-app.herokuapp.com'
  debug_output $stdout

  def play_url(url)
    self.class.post('/play', body: {url: url})
  end

  def play_text(text)
    self.class.post('/play', body: {text: text})
  end

  def save_url(title, url)
    self.class.post('/save', body: {url: url, title: title})
  end

end