require 'facebook/messenger'

Facebook::Messenger.configure do |config|
  config.access_token = 'EAALrnpYIsfYBAPqehTjiXBaEokRe9eo23q4GV3ZCRSWhPD3a8uGIX0EJh2lnEWlwsdX0wQZBXQ7PqqzEmjZA0ZBO1AHzC3C9RR1aqsidEkdTP0YkvmcsUDZBg8TbEMFBfQQjfP98k1AAU6o2UI783gLInTCQzVZBZB924M99lflmwZDZD'
  config.verify_token = 'my_voice_is_my_password_verify_me'
end

include Facebook::Messenger

bot_sessions = {}
# last_seq = -1

Bot.on :message do |message|
  # if message.seq <= last_seq
  #   return
  # end

  puts "Received #{message.text} from #{message.sender} with seq no. #{message.seq}"

  bot_session = bot_sessions[message.sender['id']]
  if bot_session.try(:[], :state) == 'save_video_flow'
    bot_session[:title] = message.text

    response = AppServerClient.new.save_url(bot_session[:title], bot_session[:url])

    if response.code == 200
      Bot.deliver(
          recipient: message.sender,
          message: {
              text: "Yay! Saved your clip.\nSend \"#{bot_session[:title]}\" to replay it."
          }
      )
    end

    bot_sessions.delete(message.sender['id'])

  elsif message.try(:attachments).try(:[], 0).try(:[], 'payload')
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
                      text: 'Your message was sent 📢',
                      buttons: [
                          {type: 'postback', title: 'Save', payload: {action: 'SAVE_CLIP', url: url}.to_json}
                      ]
                  }
              }
          }
      )
    end
  else
    text = message.text
    response = AppServerClient.new.play_text(text)
    if response.code == 200
      Bot.deliver(
          recipient: message.sender,
          message: {
              text: 'Your message was sent 📢'
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
           text: 'Please enter a title for the clip.'
       }
    )
  end
end

Bot.on :delivery do |delivery|
  puts "Received delivery with seq no. #{delivery.seq}"

  puts "Delivered message(s) #{delivery.ids}"
end

Facebook::Messenger::Subscriptions.subscribe