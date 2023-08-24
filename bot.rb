require 'telegram/bot'
require 'dotenv/load'
require 'koala'
require 'pry'

TELEGRAM_BOT_TOKEN = ENV['TELEGRAM_BOT_TOKEN']
CHAT_ID            = ENV['CHAT_ID']
FACEBOOK_APP_TOKEN = ENV['FACEBOOK_APP_TOKEN']
FACEBOOK_PAGE_ID   = ENV['FACEBOOK_PAGE_ID']

bot = Telegram::Bot::Client.new(TELEGRAM_BOT_TOKEN)

Telegram::Bot::Client.run(TELEGRAM_BOT_TOKEN) do |bot|

  bot.listen do |message|

    if message.video
      puts 'Finded new video'

      bot.api.send_message(chat_id: message.chat.id, text: "Получил видео. Обрабатываю...")

      # Сохраняем видео на сервер или используем его напрямую
      video_file = bot.api.get_file(file_id: message.video.file_id)
      video_url = "https://api.telegram.org/file/bot#{TELEGRAM_BOT_TOKEN}/#{video_file['result']['file_path']}"

      facebook_api = Koala::Facebook::API.new(FACEBOOK_APP_TOKEN)

       # Публикуем видео на Facebook
      post_id = facebook_api.put_video(video_url, { description: message.caption }, FACEBOOK_PAGE_ID)

      bot.api.send_message(chat_id: message.chat.id, text: "Опубликовано.")

    elsif message.text
      bot.api.send_message(chat_id: message.chat.id, text: "Это текст")
    else 
      bot.api.send_message(chat_id: message.chat.id, text: "Не верные данные!\n #{message.text}")
    end
  end
end
