#!/usr/bin/env ruby
# Usage : ./import-blacklist.rb <environment> 

require 'yaml'
require "json"
require "base64"
require 'net/http'
require './utils'

require './env'

argCount = ARGV.length

if (argCount != 1)
  puts("ERROR : Invalid number of parameter!!!\n")
  puts("USAGE : ./import-blacklist.rb <environment>\n")

  return
end

orgId = 'default'
apiName = 'AddBlacklist'
objectName = 'BlacklistItemData'
envName = ARGV[0]

puts("INFO : Importing blacklist for environment [#{envName}]...\n")

cfg = YAML.load_file('api.yaml')

apiObj = cfg['api'][apiName]
if (apiObj.nil?)
  puts("ERROR : API [#{apiName}] not found!!!\n")
  return 
end

cfg['api'][apiName]['body'] = objectName

endpointObj = cfg['endpoint'][envName]
if (endpointObj.nil?)
  puts("ERROR : Environment [#{envName}] not found!!!\n")
  return 
end

dataObj = Hash.new()
dataObj[objectName] = Hash.new()

File.foreach('blacklist-dst-ip.cfg') do |line|
  code, type, tags = line.strip.split(':')

  dataObj[objectName]['BlacklistCode'] = code
  dataObj[objectName]['BlacklistType'] = type
  dataObj[objectName]['Tags'] = tags

  puts("INFO : #### Importing [#{line.strip}]...\n")
  status, responseStr = invoke_api(orgId, apiName, apiObj, endpointObj, dataObj)

  if (status != '200')
    puts("ERROR : #{responseStr}\n")
  end
end
