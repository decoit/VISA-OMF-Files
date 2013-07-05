#!/usr/bin/ruby1.8

require 'rubygems'
require 'oml4r'
require 'nmap/parser'

class MPStatPing < OML4R::MPBase
	name :ping
	param :ipaddr, :type => :string
end

class MPStatPort < OML4R::MPBase
        name :port
	param :ipaddr, :type => :string
        param :port_nr, :type => :string
        param :port_proto, :type => :string
        param :port_reason, :type => :string
        param :service_name, :type => :string
end

class MPStatService < OML4R::MPBase
        name :service
        param :ipaddr, :type => :string
        param :port_nr, :type => :string
        param :port_proto, :type => :string
        param :port_reason, :type => :string
        param :service_name, :type => :string
        param :service_product, :type => :string
        param :service_version, :type => :string
end

class MPStatOs < OML4R::MPBase
        name :os
        param :ipaddr, :type => :string
	param :fingerprint, :type => :string
end

class Wrapper
        def initialize(args)              
		@addr = ""
		@scan = "-"
		@port = "-p "

		OML4R::init(args, :appName => "nmap") do |argParser|
                        argParser.banner = "\nExecute a wrapper around nmap\n\n"
                        argParser.on("-a", "--dest_addr ADDRESS", "IP adress of the target") { |address| @addr = address.to_s() }
			argParser.on("-s", "--scan SCAN", "Scantype") { |scan| @scan = @scan+scan.to_s() }
			argParser.on("-p", "--port PORT", "Port to scan") { |port| @port = @port+port.to_s() }

		end

                unless @addr != nil
                        raise "No IP-Adress specified (-a option)"
                end

        end 
        def process_output(parser)
	
		if @scan == "-sP"
                        parser.hosts("up") do |host|
                        MPStatPing.inject(host.addr)
			end
		elsif @scan == "-sT"
                        parser.hosts("up") do |host|

				[:tcp].each do |type|
                     			host.getports(type, "open") do |port|
                                	srv = port.service
					MPStatPort.inject(host.addr,port.num,port.proto,port.reason,srv.name)
                        		end
               			end
			end

                elsif @scan == "-sU"
                        parser.hosts("up") do |host|

                                [:udp].each do |type|
                                        host.getports(type, "open") do |port|
                                        srv = port.service
                                        MPStatPort.inject(host.addr,port.num,port.proto,port.reason,srv.name)
                                        end
                        	end
               		end

		elsif @scan == "-sV"
                        parser.hosts("up") do |host|

                                [:tcp, :udp].each do |type|
                                        host.getports(type, "open") do |port|
                                        srv = port.service
                                        MPStatService.inject(host.addr,port.num,port.proto,port.reason,srv.name,srv.product,srv.version)
                                        end
				end
                        end
		elsif @scan == "-O"
                	parser.hosts("up") do |host|
				lines = host.os.fingerprint.split("\n")
				finger=""
				lines.each do |line|
					finger=finger+line
				end
                                MPStatOs.inject(host.addr,finger)
			end

		end
		sleep 1
	end

	def start()

		if @scan == "-sP" || @scan == "O"

			@port=nil

		end

		parser = Nmap::Parser.parsescan("sudo nmap", "#{@scan} #{@addr} #{@port}")

		process_output(parser)

	end
end

begin
        app = Wrapper.new(ARGV)
        app.start();
rescue Exception => ex
        puts "Received an Exception when executing the wrapper!"
        puts "The Exception is: #{ex}\n"
end
