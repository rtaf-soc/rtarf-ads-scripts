#!/usr/bin/env ruby
# Usage : ./test-api.rb <environment> <api-name> 

require 'yaml'
require "json"
require "base64"
require 'net/http'
require './utils'

require './env'

##### Main #####
argCount = ARGV.length

if (argCount != 2)
  puts("ERROR : Invalid number of parameter!!!\n")
  puts("USAGE : ./test-api.rb <environment> <api-name>\n")

  return
end

orgId = 'default'
envName = ARGV[0]
apiName = ARGV[1]

puts("INFO : Testing API [#{apiName}] for environment [#{envName}]...\n")

cfg = YAML.load_file('api.yaml')

apiObj = cfg['api'][apiName]
if (apiObj.nil?)
  puts("ERROR : API [#{apiName}] not found!!!\n")
  return 
end

endpointObj = cfg['endpoint'][envName]
if (endpointObj.nil?)
  puts("ERROR : Environment [#{envName}] not found!!!\n")
  return 
end

dataObj = cfg['data']

status, responseStr = invoke_api(orgId, apiName, apiObj, endpointObj, dataObj)

puts("INFO : Returned with status code [#{status}]\n")
if (status == "200")
  puts("INFO : ===== Begin response data =====\n")
  puts("#{responseStr}\n")
  puts("INFO : ===== End response data =====\n")
end
