#!/usr/bin/env ruby
# Usage : ./import-members.rb <member.txt> 

require 'yaml'
require "json"
require "base64"
require 'net/http'
require './utils'

require './env'

argCount = ARGV.length

if (argCount != 1)
  puts("ERROR : Invalid number of parameter!!!\n")
  puts("USAGE : ./import-members.rb <member.txt>\n")

  return
end

memberFile = ARGV[0]

### Connect
uri = "https://logstash-http.rtarf-prod.its-software-services.com/"
puts("INFO : Using URI [#{uri}]\n")

uriObj = URI.parse(uri)
https = Net::HTTP.new(uriObj.host, uriObj.port)

useSSL = true
if m = uri.match(/^http:\/\/(.+?)$/)
  useSSL = false
end
###

File.foreach(memberFile) do |line|
  name, group, nickname, os, phone = line.strip.split(';')

  puts("INFO : #### Importing [#{name}]...\n")

  https.use_ssl = useSSL
  https.verify_mode = OpenSSL::SSL::VERIFY_NONE
  https.read_timeout = 10
  https.open_timeout = 10
  https.max_retries = 0

  request = Net::HTTP::Post.new(uriObj.path)
  jsonStr = '{}'

  bodyObj = Hash.new()

  bodyObj['name'] = name
  bodyObj['group'] = group
  bodyObj['nickname'] = nickname
  bodyObj['system'] = os
  bodyObj['contact'] = phone

  if (!bodyObj.nil?)
    # Convert to JSON
    jsonStr = bodyObj.to_json
    puts(jsonStr)
  end

  request['Accept'] = 'application/json'
  request['Content-Type'] = 'application/json'
  request.body = jsonStr

  status = ""
  begin
    response = https.request(request)
  rescue
      status = 'ERROR'
  else
      #No error
      status = response.code
      responseStr = response.body
  end

  if (status != '200')
    puts("ERROR : #{responseStr}\n")
  end

end
