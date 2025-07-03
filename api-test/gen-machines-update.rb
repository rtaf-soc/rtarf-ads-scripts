#!/usr/bin/env ruby

require 'json'

if File.exist?('env.rb')
  #Default environment variables
  require './env'
end

# Read file and insert line by line
cnt = 0
File.foreach('machine.csv') do |line|
  cnt = cnt + 1

  line = line.strip
  next if line.empty?

  machine, tags = line.split('|')
  zone = ""
  if (tags =~ /^SensorGroupingTags\/(.+?),.+$/)
    zone = $1
  end

  tableName = "\"CsMachineStat\""
  puts("UPDATE #{tableName} SET department_name = '#{zone}' WHERE machine_name = '#{machine}';")
end
