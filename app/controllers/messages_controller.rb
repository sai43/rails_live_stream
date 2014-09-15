#require 'streamer/sse'

class MessagesController < ApplicationController
  include ActionController::Live

  def index
    @messages = Message.all
  end

  def create
    response.headers['Content-Type'] = 'text/javascript'
    attributes = params.require(:message).permit(:name, :content)
    @messages  = Message.create!(attributes) 

    $redis.publish('messages.create', @message.to_json)
    #render nothing: true
  end

  def events
      response.headers['Content-Type'] = 'text/event-stream'
      start = Time.zone.now

      redis = Redis.new
      redis.subscribe('messages.create') do |on|
              on.message do |event, data|
                response.stream.write("data: #{data}\n\n")
              end
        end
   rescue IOError
       logger.info "stream closed"
   
   ensure
     redis.quit
     response.stream.close
  end
end


=begin

10.times do 
         Message.uncached do 
                 Message.where('created_at > ?',start).each do |message|
                  response.stream.write "data: #{message.to_json}\n\n"
                  start = message.created_at
                  end
             end     
         sleep 2        
      end
=end
