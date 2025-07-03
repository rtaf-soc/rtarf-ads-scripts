#!/usr/bin/env ruby

require 'json'
require 'pg'
require 'ipaddr'

if File.exist?('env.rb')
  #Default environment variables
  require './env'
end

pgHost = ENV['PG_HOST']
pgPort = ENV['PG_PORT']
pgUser = ENV['PG_USER']
pgPassword = ENV['PG_PASSWORD']
pgDB = ENV['PG_DB']

def connect_db(host, db, user, password, port)
  begin
      con = PG.connect(:host => host, 
          :dbname => db, 
          :user => user, 
          :port => port,  
          :password => password)

  rescue PG::Error => e
      puts("ERROR - Connect to DB [#{e.message}]")
  end

  return con
end

def escape_char(str)
  return "#{str}".tr("'", "")
end

def load_cidr_map(conn)
  puts("INFO : Loading CIDR map to memory...")
  rec_map = Array.new()

  cnt = 0
  if (conn)
    rs = conn.exec "SELECT cidr, zone FROM \"IpMaps\""
    rs.each do |row|
      obj = {
        "cidr" => row['cidr'],
        "zone" => row['zone'], 
        "cidr_net" => IPAddr.new(row['cidr']),
      }

      rec_map.push(obj)
      cnt = cnt + 1

#puts("cidr=[#{obj['cidr']}], zone=[#{obj['zone']}]")
    end
  end

  puts("INFO : Done loading [#{cnt}] CIDR to memory.")
  return rec_map
end

def get_zone(cidrArr, ip)
  if (ip.nil? || (ip == ''))
    return '==unknown=='
  end

  net1 = IPAddr.new(ip)

  cidrArr.each do |obj|
    zone = obj['zone']
    cidr = obj['cidr']
    cidr_net = obj['cidr_net']
        
    if (cidr_net.include?(net1))
      return zone
    end
  end

  return '==unknown=='
end

def upsertData(dbConn, obj, seq)
  name = obj['name']
  zone = obj['zone']
  ip = obj['ip']

  orgId = "default"
  
  begin
    dbConn.transaction do |con|
        con.exec "INSERT INTO \"CsMachineStat\" 
        (
          machine_stat_id,
          machine_name,
          last_cs_event_date,
          org_id,
          cs_event_count,
          created_date,
          department_name
        )
        VALUES
        (
          gen_random_uuid(),
          '#{escape_char(name)}',
          CURRENT_TIMESTAMP,
          '#{escape_char(orgId)}',
          0,
          CURRENT_TIMESTAMP,
          '#{escape_char(zone)}'
        )
        ON CONFLICT(machine_name)
        DO UPDATE SET 
          last_cs_event_date = CURRENT_TIMESTAMP,
          department_name = '#{escape_char(zone)}'
        "
    end
  rescue PG::Error => e
    puts("ERROR - Insert data to DB upsertData() [#{e.message}]")
    exit 102 # Terminate immediately
  end
end


puts("INFO - Connecting to host=[#{pgHost}], port=[#{pgPort}], DB=[#{pgDB}]")

conn = connect_db(pgHost, pgDB, pgUser, pgPassword, pgPort)
if (conn.nil?)
  puts("ERROR : ### Unable to connect to PostgreSQL!!! [#{pgHost}] [#{pgDB}]")
  exit 101
end

puts("INFO : ### Connected to PostgreSQL [#{pgHost}] [#{pgDB}]")

cidrArr = load_cidr_map(conn)

# Read file and insert line by line
cnt = 0
File.foreach('machine.csv') do |line|
  cnt = cnt + 1

  line = line.strip
  next if line.empty?

  machineName, ipAddress = line.split(',')
  zone = get_zone(cidrArr, ipAddress)

  obj = {
    "name" => machineName,
    "zone" => zone,
    "ip" => ipAddress,
  }

  puts("INFO : ### Updating data for machine [#{machineName}], IP=[#{ipAddress}], Zone=[#{zone}]")

  tableName = "\"CsMachineStat\""
  puts("INSERT INTO #{tableName} (machine_stat_id, machine_name, last_cs_event_date, department_name) VALUES (gen_random_uuid(), '#{machineName}', CURRENT_TIMESTAMP, '#{zone}');")
  #upsertData(conn, obj, cnt)
end

puts("INFO : ### Done updating [#{cnt}] records.")
