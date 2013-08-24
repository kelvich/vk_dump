#!/usr/bin/env ruby
require "rubygems"
require "json"
require "uri"
require "open-uri"

# https://oauth.vk.com/authorize?client_id=3838855&scope=4096&response_type=token

class VK
  API_URL = "https://api.vk.com"
  MSG_COUNT = 200
  
  def initialize(token)
    @token = token
  end
  
  def messages_get(direction, offset=0)
    uri = URI(API_URL)
    uri.path = "/method/messages.get"
    uri.query = {
      :offset => offset,
      :preview_length => 0,
      :count => 200,
      :out => direction == :in ? 0 : 1,
      :access_token => @token
    }.map{|k,v| "#{k}=#{v}"}.join('&')
    uri.read
  end
  
  def load_all(direction)
    max = messages_get(:in,  100000000000)[/\d+/].to_i
    puts "#{max} #{direction} messages"
    messages = []
    (0..max).step(MSG_COUNT).each do |offset|
      messages << JSON.load(messages_get(direction, offset))['response']
      print "\rReceived messages: saved #{offset} of #{max} total"
      sleep 0.3
    end
    messages
  end

end

api = VK.new(ARGV[0])

File.open("messages.in.json", 'w') do |f|
  f.write JSON.dump(api.load_all(:in))
end

File.open("messages.out.json", 'w') do |f|
  f.write JSON.dump(api.load_all(:out))
end



