#!/usr/bin/env ruby

require 'watir'
require 'json'

require './env'

# ใส่ข้อมูล TheHive server
thehive_url = 'http://10.141.98.47:9000/index.html#/login'
username = ENV['HIVE_USER']
password = ENV['HIVE_PASSWORD']

# เปิด browser (headless mode)
browser = Watir::Browser.new(:chrome, headless: true)

# ไปหน้า login
browser.goto(thehive_url)

# รอให้ input ปรากฏ (กันโหลดไม่ทัน)
browser.text_field(placeholder: 'Login').wait_until(&:present?)
browser.text_field(placeholder: 'Password').wait_until(&:present?)

# กรอก username + password
browser.text_field(placeholder: 'Login').set(username)
browser.text_field(placeholder: 'Password').set(password)

# คลิกปุ่ม login
browser.button(text: /Sign In/i).click

# รอหน้าโหลดหลัง login (เช่น Dashboard)
#browser.div(text: /Dashboard/i).wait_until(&:present?)

browser.goto('http://10.141.98.47:9000')
sleep 3

browser.goto('http://10.141.98.47:9000/api/case?range=0-3')
sleep 3

jsonStr = browser.text
prettyJsonStr = JSON.pretty_generate(JSON.parse(jsonStr))

puts prettyJsonStr

# ปิด browser
browser.close
