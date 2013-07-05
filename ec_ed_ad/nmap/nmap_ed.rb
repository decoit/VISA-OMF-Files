#Application Definition
defApplication('nmap_ad', 'nmapscanner') do |app|
        app.path = "/usr/bin/nmap_wr.rb"
        app.version(1, 0, 0)
        app.shortDescription = "Wrapper around nmap"
        app.description = "nmap scanner"

        app.defProperty('dest_addr', 'IP Adress to scan', '-a', {:order => 2, :type => :string, :dynamic => false})
	app.defProperty('scan', 'Nmap scantype', '-s', {:order => 1, :type => :string, :dynamic => false, :use_name => false})
	app.defProperty('port', 'Port to scan', '-p', {:order => 3, :type => :string, :dynamic => false})

        app.defMeasurement('ping') do |m|
                m.defMetric('ipaddr',:string)
        end

        app.defMeasurement('port') do |m|
                m.defMetric('ipaddr',:string)
                m.defMetric('port_nr',:string)
                m.defMetric('port_proto',:string)
                m.defMetric('port_reason',:string)
                m.defMetric('service_name',:string)
        end

        app.defMeasurement('service') do |m|
                m.defMetric('ipaddr',:string)
                m.defMetric('port_nr',:string)
                m.defMetric('port_proto',:string)
                m.defMetric('port_reason',:string)
                m.defMetric('service_name',:string)
                m.defMetric('service_product',:string)
                m.defMetric('service_version',:string)
        end

        app.defMeasurement('os') do |m|
                m.defMetric('ipaddr',:string)
		m.defMetric('fingerprint',:string)
        end

end

#Experiment Description
defProperty('source', "omf.decoit.node1", "ID of a resource")
defProperty('target', "omf.decoit.node2", "ID of a resource")
defProperty('dest_addr', '10.240.0.5', "Scan destination address")
defProperty('scan', 'sT', "Scan type")
defProperty('port', '1-10000', "Port to scan")

defGroup('Source', property.source) do |node|
  node.addApplication("nmap_ad") do |app|
    app.setProperty('dest_addr', property.dest_addr)
    app.setProperty('scan', property.scan)
    app.setProperty('port', property.port)
    app.measure('ping', :samples => 1)
    app.measure('port', :samples => 1)
    app.measure('service', :samples => 1)
  end
end

defEvent(:SCAN_COMPLETED) do |event|
  app_status = allGroups.state("apps/app/status/@value")
  if allEqual(app_status, "DONE.OK")
  info "Scan Completed"
    event.fire 
  end
end

onEvent(:SCAN_COMPLETED) do |event|
  allGroups.stopApplications
  info "Nmap stopped now."
  Experiment.done
end

onEvent(:ALL_UP_AND_INSTALLED) do |event|
  info "Starting nmap"
  group("Source").startApplications
  info "Nmap started now..."
end

