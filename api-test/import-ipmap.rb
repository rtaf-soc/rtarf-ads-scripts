#!/usr/bin/env ruby
# Usage : ./import-ipmap.rb <environment> 

require 'yaml'
require "json"
require "base64"
require 'net/http'
require './utils'

require './env'

argCount = ARGV.length

if (argCount != 1)
  puts("ERROR : Invalid number of parameter!!!\n")
  puts("USAGE : ./import-ipmap.rb <environment>\n")

  return
end

orgId = 'default'
apiName = 'AddIpMap'
objectName = 'IpMapItemData'
envName = ARGV[0]

puts("INFO : Importing ip map for environment [#{envName}]...\n")

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

File.foreach('ipmap.cfg') do |line|
  cidr, zone, desc = line.strip.split(':')

  dataObj[objectName]['Cidr'] = cidr
  dataObj[objectName]['Zone'] = zone
  dataObj[objectName]['Description'] = "Imported from script"

  puts("INFO : #### Importing [#{line.strip}]...\n")
  status, responseStr = invoke_api(orgId, apiName, apiObj, endpointObj, dataObj)

  if (status != '200')
    puts("ERROR : #{responseStr}\n")
  end
end
