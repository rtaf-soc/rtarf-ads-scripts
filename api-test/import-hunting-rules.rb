#!/usr/bin/env ruby
# Usage : ./import-members.rb <member.txt> 

require 'yaml'
require "json"
require "base64"
require 'net/http'
require './utils'

require './env'

argCount = ARGV.length


if (argCount != 2)
  puts("ERROR : Invalid number of parameter!!!\n")
  puts("USAGE : ./import-hunting-rules.rb <env> <Suricata|Yara|Sigma>\n")

  return
end

envName = ARGV[0]
ruleType = ARGV[1]

allowType = ['Suricata', 'Yara', 'Sigma']

if (!allowType.include?(ruleType))
  puts("ERROR : Invalid rule type!!!\n")
  puts("USAGE : ./import-hunting-rules.rb <env> <Suricata|Yara|Sigma>\n")

  return
end

puts("INFO : Importing blacklist for environment [#{envName}]...\n")

cfg = YAML.load_file('api.yaml')
orgId = 'default'
apiName = 'AddHuntingRule'
objectName = 'HuntingRuleSigma1'

apiObj = cfg['api'][apiName]
if (apiObj.nil?)
  puts("ERROR : API [#{apiName}] not found!!!\n")
  return 
end

tmpGitDir = "/tmp"
typeConfigHash = {
  'Suricata' => { 'name' => 'suricata', 'git' => 'https://github.com/OISF/suricata-update.git', 'dir' => 'rules', 'ext' => 'aaa' },
  'Yara' => { 'name' => 'yara', 'git' => 'https://github.com/Yara-Rules/rules.git', 'dir' => 'rules', 'ext' => 'yar' },
  'Sigma' => { 'name' => 'sigma', 'git' => 'https://github.com/SigmaHQ/sigma.git', 'dir' => 'rules', 'ext' => 'yml' }
}

cfg['api'][apiName]['body'] = objectName

endpointObj = cfg['endpoint'][envName]
if (endpointObj.nil?)
  puts("ERROR : Environment [#{envName}] not found!!!\n")
  return 
end

dataObj = Hash.new()
dataObj[objectName] = Hash.new()

dataObj[objectName]['RuleName'] = "crypto_signatures"
dataObj[objectName]['RuleDescription'] = "crypto_signatures"
dataObj[objectName]['RefType'] = ruleType
dataObj[objectName]['RuleDefinition'] = 'content'
dataObj[objectName]['RefUrl'] = ""
dataObj[objectName]['Tags'] = "crypto"

#puts("INFO : #### Importing [#{line.strip}]...\n")
#status, responseStr = invoke_api(orgId, apiName, apiObj, endpointObj, dataObj)
#puts ("DDDD [#{status}] #####")
#if (status != '200')
#  puts("ERROR : #{responseStr}\n")
#end

tmpDir = "temp"

gitConfig = typeConfigHash[ruleType]
gitRepo = gitConfig['git']
gitName = gitConfig['name']
ext = gitConfig['ext']
subDir = gitConfig['dir']

cmdOutput = `rm -rf #{tmpDir}/#{gitName}`
cmdOutput = `git clone #{gitRepo} #{tmpDir}/#{gitName}`

Dir.glob("#{tmpDir}/#{gitName}/**/*") do |fileName|
  next if fileName == '.' or fileName == '..'

  next if !fileName.end_with?("#{ext}")

  content = `cat #{fileName}`
  dirName = File.dirname(fileName)
  baseName = File.basename(fileName, ".#{ext}")
  tags = baseName.split('_').join(",")

  dataObj[objectName]['RuleName'] = File.basename(fileName)
  dataObj[objectName]['RuleDescription'] = dirName
  dataObj[objectName]['RefType'] = ruleType
  dataObj[objectName]['RuleDefinition'] = content
  dataObj[objectName]['RefUrl'] = gitRepo
  dataObj[objectName]['Tags'] = tags
  
  puts("INFO : #### Importing [#{fileName}] [#{tags}]...\n")
  status, responseStr = invoke_api(orgId, apiName, apiObj, endpointObj, dataObj)
  if (status != '200')
    puts("ERROR : #{responseStr}\n")
  end
end
