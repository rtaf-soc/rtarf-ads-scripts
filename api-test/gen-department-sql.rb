#!/usr/bin/env ruby

require 'json'

if File.exist?('env.rb')
  #Default environment variables
  require './env'
end

# Read file and insert line by line
cnt = 0
File.foreach('department.csv') do |line|
  cnt = cnt + 1

  line = line.strip
  next if line.empty?

  code, shortName, longName = line.split(',')

  tableName = "\"Departments\""
  puts("INSERT INTO #{tableName} (department_id, department_code, org_id, short_name, long_name, created_date) VALUES (gen_random_uuid(), '#{code}', 'default', '#{shortName}', '#{longName}', CURRENT_TIMESTAMP);")
end
