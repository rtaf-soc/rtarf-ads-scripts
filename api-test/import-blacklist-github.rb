#!/usr/bin/env ruby
# Usage : ./import-blacklist-github.rb <environment> 

require 'yaml'
require "json"
require "base64"
require 'net/http'
require './utils'

require './env'

argCount = ARGV.length

if (argCount != 1)
  puts("ERROR : Invalid number of parameter!!!\n")
  puts("USAGE : ./import-blacklist-github.rb <environment>\n")

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

srcDataObj = Hash.new()
srcDataObj[objectName] = Hash.new()

dstDataObj = Hash.new()
dstDataObj[objectName] = Hash.new()

File.foreach('blacklist-github.cfg') do |line|
  code = line.strip

  srcDataObj[objectName]['BlacklistCode'] = code
  srcDataObj[objectName]['BlacklistType'] = '1'
  srcDataObj[objectName]['Tags'] = 'Imported from GitHub'

  dstDataObj[objectName]['BlacklistCode'] = code
  dstDataObj[objectName]['BlacklistType'] = '2'
  dstDataObj[objectName]['Tags'] = 'Imported from GitHub'

  puts("INFO : #### Importing [#{line.strip}]...\n")

  status, responseStr = invoke_api(orgId, apiName, apiObj, endpointObj, srcDataObj)
  if (status != '200')
    puts("ERROR : #{responseStr}\n")
  end

  status, responseStr = invoke_api(orgId, apiName, apiObj, endpointObj, dstDataObj)
  if (status != '200')
    puts("ERROR : #{responseStr}\n")
  end

end
