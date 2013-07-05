#!/usr/bin/ruby1.8

require 'rubygems'
require 'oml4r'

class MPStat < OML4R::MPBase
	name :t50
	param :address, :type => :string
	param :attack_type, :type => :string
	param :packets, :type => :string
	param :duration, :type => :string
end

class Wrapper
        def initialize(args)              
		@addr = ""
		@attack = "--"
		@count = "0"
		@duration = 0
		OML4R::init(args, :appName => "t50") do |argParser|
                        argParser.banner = "\nExecute a wrapper around t50\n\n"
                        argParser.on("-a", "--dest_addr ADDRESS", "IP adress of the target") { |address| @addr = address.to_s() }
			argParser.on("-t", "--attack ATTACK", "Type of attack") { |attack| @attack = @attack+attack.to_s() }
			argParser.on("-c", "--count COUNT", "Number of Pakets") { |count| @count = count.to_s() }
			argParser.on("-d", "--duration DURATION", "Duration of attack") { |duration| @duration = duration.to_i() }
		end

                unless @addr != nil
                        raise "No IP-Adress specified (-a option)"
                end

        end 
        def process_output()

                MPStat.inject(@addr,@attack,@count,@duration)
		sleep 1
	end
	def t50flood()

		t1=Thread.new{
		`/usr/bin/t50 --flood #{@addr}`
		}

		pids = `ps -ef | grep "/usr/bin/t50 " | grep -v grep | awk '{print $2}'`
		pid = pids.to_i()

		sleep @duration               

		Process.kill('INT', pid) 
		
		process_output()

	end
	def t50threshold()

                `/usr/bin/t50 --threshold #{@count} #{@addr}`

                process_output()

	end

	def start()

		if @attack=='--flood'
		t50flood()
		end
		if @attack=='--threshold'
		t50threshold()
		end

	end
end

begin
        app = Wrapper.new(ARGV)
        app.start();
rescue Exception => ex
        puts "Received an Exception when executing the wrapper!"
        puts "The Exception is: #{ex}\n"
end

