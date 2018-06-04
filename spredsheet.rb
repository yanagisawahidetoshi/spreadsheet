require 'selenium-webdriver'
require 'date'
require 'open-uri'
require 'yaml'

YAML.load('config.yml')

class Attendance
	attr_accessor :startTime, :endTime, :targetDateObj

	class << self
		def run
			@startTime = ""
			@endTime = ""

			build_target_date
			work_time
			exit if @startTime.empty? || @endTime.empty?
			send_worktime_data
		end

		private

		def build_target_date
			# 月曜日の場合は金曜日のログを取得する。それ以外は前日のログを取得する
			if DateTime.now.wday == 1
				@targetDateObj = DateTime.now - 3
			else
				@targetDateObj = DateTime.now - 1
			end
		end

		def work_time
			targetDate = @targetDateObj.strftime('%Y-%m-%d')

			`pmset -g log | grep "Kernel Idle sleep preventers"`.each_line do |line|
				lines = line.split(/\t/)
				date = DateTime.parse(lines.first)
				next unless targetDate == date.strftime('%Y-%m-%d')

				@startTime = build_time(date) if @startTime.empty? && lines[1].include?("IODisplayWrangler")
				@endTime = build_time(date) if lines[1].include?("-None-")
			end
		end

		def send_worktime_data
			yaml = YAML.load_file('config.yml')
			url = build_url(yaml)

			options = Selenium::WebDriver::Chrome::Options.new
			# options.add_argument('--headless')
	    driver = Selenium::WebDriver.for :chrome
	    driver.get url
	    wait = Selenium::WebDriver::Wait.new(:timeout => 100)

			# メールアドレス入力	    
	    wait.until {driver.find_element(:id, 'identifierId').displayed?}
			input_mail_address = driver.find_element(:id, 'identifierId')
			input_mail_address.send_keys yaml["mail"]
			wait.until {driver.find_element(:id, 'identifierNext').displayed?}
			driver.find_element(:id, 'identifierNext').click
			
			# パスワード入力
			wait.until {driver.find_element(:id, 'password').displayed?}
			input_password = driver.find_element(:id, 'password').find_element(:tag_name, 'input')
			input_password.send_keys yaml["password"]
			driver.find_element(:id, 'passwordNext').click

			sleep 10
		end

		def build_time(date)
			min = date.strftime('%M').to_i / 15 * 15
			"#{date.strftime('%H')}:#{format("%02d", min)}"
		end

		def build_url(yaml)
			date = @targetDateObj.strftime('%-d')
			URI.encode("https://script.google.com/macros/s/AKfycbyJOA60ODVQaKJUYpqyEw69njiAjbApRjYXKqV86Ieat__TSWs/exec?date=#{date}&start=#{@startTime}&end=#{@endTime}&sheetId=#{yaml["bookId"]}&sheetName=#{yaml["sheetName"]}")
		end
	end
end

Attendance.run
