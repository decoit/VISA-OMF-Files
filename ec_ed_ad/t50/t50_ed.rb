#Application Definition
defApplication('t50_ad', 't50') do |app|
        app.path = "/usr/bin/t50_wr.rb"
        app.version(1, 0, 0)
        app.shortDescription = "Wrapper around t50"
        app.description = "t50 dos tool"

        app.defProperty('dest_addr', 'IP Adress to scan', '-a', {:order => 3, :type => :string, :dynamic => false})
	app.defProperty('attack', 'Type of attack', '-t', {:order => 1, :type => :string, :dynamic => false})
	app.defProperty('count', 'Count of pakets to send', '-c', {:order => 2, :type => :int, :dynamic => false})
        app.defProperty('duration', 'Duration of sending pakets', '-d', {:type => :int, :dynamic => false})

        app.defMeasurement('t50') do |m|
                m.defMetric('address',:string)
                m.defMetric('attack_type',:string)
                m.defMetric('packets',:string)
                m.defMetric('duration',:string)
        end
end

#Experiment Description
defProperty('source', "omf.decoit.node1", "ID of a resource")
defProperty('target', "omf.decoit.node2", "ID of a resource")
defProperty('dest_addr', '10.240.1.201', "Scan destination address")
defProperty('attack', 'flood', "Attack type")
defProperty('count', 500000, "Pakets to send")
defProperty('duration', 10, "Duration of sending pakets")

defGroup('Source', property.source) do |node|
  node.addApplication("t50_ad") do |app|
    app.setProperty('dest_addr', property.dest_addr)
    app.setProperty('attack', property.attack)
    app.setProperty('count', property.count)
    app.setProperty('duration', property.duration)
    app.measure('t50', :samples => 1)
  end
end

defGroup('Target', property.target) do |node|
end

defEvent(:ATTACK_COMPLETED) do |event|
  app_status = allGroups.state("apps/app/status/@value")
  if allEqual(app_status, "DONE.OK")
  info "T50 completed"
    event.fire
  end
end

onEvent(:ATTACK_COMPLETED) do |event|
  allGroups.stopApplications
  info "T50 stopped now."
  Experiment.done
end

onEvent(:ALL_UP_AND_INSTALLED) do |event|
  group("Source").startApplications
  info "T50 started now..."
end

