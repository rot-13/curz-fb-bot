require 'facebook/messenger'

Facebook::Messenger.configure do |config|
  config.access_token = 'EAALrnpYIsfYBAE5uNGBCFKNKSCMbqwNjs4bXZBl7ZBIOc0wyer3n51cQP6VHvOK1ANAcq4VZCWk7sU8xIOPeUsPpcsZC5oEfvycErguVZBMUI5Ep6lP8mKZAApYA8KNvqtBAFanHeDhgG96exT2gaBqgvZCrnFZB5IvoYfCGweC5uQZDZD'
  config.verify_token = 'my_voice_is_my_password_verify_me'
end

include Facebook::Messenger

Bot.on :message do |message|
  puts "Received #{message.text} from #{message.sender}"

  Bot.deliver(
      recipient: message.sender,
      message: {
          text: 'Hello, human!'
      }
  )
end

Bot.on :delivery do |delivery|
  puts "Delivered message(s) #{delivery.ids}"
end

Facebook::Messenger::Subscriptions.subscribe