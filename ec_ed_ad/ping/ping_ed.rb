#Application Definition
defApplication('ping_ad', 'pingmonitor') do |a|
    a.path = "/usr/bin/ping_wr.rb" 
    a.version(1, 2, 0)
    a.shortDescription = "Wrapper around ping" 
    a.description = "ping application" 
    a.defProperty('dest_addr', 'Address to ping', '-a', {:type => :string, :dynamic => false})
    a.defProperty('count', 'Number of times to ping', '-c', {:type => :integer, :dynamic => false}) 
    a.defProperty('interval', 'Interval between pings in s', '-i', {:type => :integer, :dynamic => false})

    a.defMeasurement('ping') do |m|
     m.defMetric('dest_addr',:string) 
     m.defMetric('ttl',:int)
     m.defMetric('rtt',:float)
     m.defMetric('rtt_unit',:string)
   end
end

#Experiment Description
defProperty('source', "omf.decoit.node1", "ID of a resource")
defProperty('address', 'www.nicta.com.au', "Ping destination address")
defProperty('count', 5, "Number of pings")
defProperty('interval', 5, "Time between pings")

defGroup('Source', property.source) do |node|
  node.addApplication("ping_ad") do |app|
    app.setProperty('dest_addr', property.address)
    app.setProperty('count', property.count)
    app.setProperty('interval', property.interval)
    app.measure('ping', :samples => 1)
  end
end

defEvent(:PING_COMPLETED) do |event|
  app_status = allGroups.state("apps/app/status/@value")
  if allEqual(app_status, "DONE.OK")
  info "Ping Completed"
    event.fire
  end
end

onEvent(:PING_COMPLETED) do |event|
  allGroups.stopApplications
  info "Ping stopped now."
  Experiment.done
end

onEvent(:ALL_UP_AND_INSTALLED) do |event|
  info "Starting ping" 
  group('Source').startApplications
end
