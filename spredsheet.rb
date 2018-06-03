require 'selenium-webdriver'
require 'date'
require 'open-uri'
require 'yaml'

YAML.load('config.yml')

class Attendance
	attr_accessor :startTime, :endTime

	class << self
		def run
			@startTime = ""
			@endTime = ""

			work_time
			send_worktime_data
		end

		private

		def work_time
			yesterday = (DateTime.now - 1).strftime('%Y-%m-%d')
			`pmset -g log | grep "Kernel Idle sleep preventers"`.each_line do |line|
				lines = line.split(/\t/)
				date = DateTime.parse(lines.first)
				next unless yesterday == date.strftime('%Y-%m-%d')
				
				time = build_time(date)
				
				if @startTime.empty? && lines[1].include?("IODisplayWrangler")
					@startTime = time
				end

				if lines[1].include?("-None-")
					@endTime = time
				end
			end
		end


		def send_worktime_data
			yaml = YAML.load_file('config.yml')

			date = (DateTime.now - 1).strftime('%-d')

			url = "https://script.google.com/macros/s/AKfycbyJOA60ODVQaKJUYpqyEw69njiAjbApRjYXKqV86Ieat__TSWs/exec?date=#{date}&start=#{@startTime}&end=#{@endTime}"

			options = Selenium::WebDriver::Chrome::Options.new
	    driver = Selenium::WebDriver.for :chrome
	    driver.get url
	    sleep 3

			nput_mail_address = driver.find_element(:id, 'identifierId')
			input_mail_address.send_keys yaml["mail"]
			driver.find_element(:id, 'identifierNext').click
			sleep 3

			nput_password = driver.find_element(:id, 'password').find_element(:tag_name, 'input')
			input_password.send_keys yaml["password"]
			driver.find_element(:id, 'passwordNext').click

			sleep 10

			driver.find_element(:class_name, "waffle-borderless-embedded-object-container").click
		end

		def build_time(date)
			min = date.strftime('%M').to_i / 15 * 15
			"#{date.strftime('%H')}:#{format("%02d", min)}"
		end
	end
end

Attendance.run
