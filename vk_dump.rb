#!/usr/bin/env ruby
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
    uri.query = URI.encode_www_form({
      :offset => offset,
      :preview_length => 0,
      :count => 200,
      :out => direction == :in ? 0 : 1,
      :access_token => @token
    })
    uri.read
  end
  
end

api = VK.new(ARGV[0])

in_max =  JSON.load(api.messages_get(:in,  100000000000))['response'][0]
out_max = JSON.load(api.messages_get(:out, 100000000000))['response'][0]

puts "Received: #{in_max}, Sended: #{out_max}"

file_in = File.open("messages.in.json", 'w')
(0..in_max).step(VK::MSG_COUNT).each do |offset|
  file_in.write api.messages_get(:in, offset)
  print "\rReceived messages: saved #{offset} of #{in_max} total"
  sleep 0.3
end

file_out = File.open("messages.out.json", 'w')
(0..out_max).step(VK::MSG_COUNT).each do |offset|
  file_out.write api.messages_get(:out, offset)
  print "\rSended messages: saved #{offset} of #{in_max} total"
  sleep 0.3
end



