require 'facebook/messenger'

Facebook::Messenger.configure do |config|
  config.access_token = 'EAALrnpYIsfYBABTgci00sInHqxB4KYbqCKwVM3546iEBnITSQFHZCXOYpuqfmGfg8IPC05Ph57DEuQJUbUXjQ47TLWK04pDponL1oYczZAGlowktjUiA8zYdUfMsoNsQH3Lwwq6oVs8p9cuiORwJEpMVBnxBHluKVgVdMtBAZDZD'
  config.verify_token = 'my_voice_is_my_password_verify_me'
end

include Facebook::Messenger

bot_sessions = {}

Bot.on :message do |message|
  puts "Received #{message.text} from #{message.sender}"

  bot_session = bot_sessions[message.sender['id']]
  if bot_session.try(:[], :state) == 'save_video_flow'
    bot_session[:title] = message.text

    # TODO: Save clip using AppServerClient

    Bot.deliver(
      recipient: message.sender,
      message: {
        text: "Saved video with title #{bot_session[:title]}"
      }
    )

    hash.delete(message.sender['id'])
    return
  end

  if message.try(:attachments).try(:[], 0).try(:[], 'payload')
    url = message.attachments[0]['payload']['url']
    response = AppServerClient.new.play_url(url)
    if response.code == 200 && response.parsed_response.starts_with?('playing')
      Bot.deliver(
          recipient: message.sender,
          message: {
              attachment: {
                  type: 'template',
                  payload: {
                      template_type: 'button',
                      text: 'Do you like to save it?',
                      buttons: [
                          {type: 'postback', title: 'Save', payload: {action: 'SAVE_CLIP', url: url}.to_json}
                      ]
                  }
              }
          }
      )
    end
  end

end

Bot.on :postback do |postback|
  payload = JSON.parse(postback.payload)

  if payload['action'] == 'SAVE_CLIP'
    bot_sessions[postback.sender['id']] = {state: 'save_video_flow', url: payload['url']}
    Bot.deliver(
       recipient: postback.sender,
       message: {
           text: 'Please enter a title for the clip'
       }
    )
  end
end


Bot.on :delivery do |delivery|
  puts "Delivered message(s) #{delivery.ids}"
end

Facebook::Messenger::Subscriptions.subscribe