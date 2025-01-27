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

File.foreach(memberFile) do |line|
  name, group, nickname, os, phone = line.strip.split(';')

  puts("INFO : #### Importing [#{name}]...\n")
end
