require 'omf_web'
require 'omf_common/lobject'
require 'omf_oml/table'
require 'omf_oml/sql_source'


class NmapDB < OMF::Common::LObject
  
#  LINKS = {'Source1' => 'link 1',
#          }
  
  def initialize(db_name)
    @db_name = db_name
  end
  
  def setup_table(stream)
    schema = stream.schema.clone
#    schema.insert_column_at(0, :link)
    puts stream.schema.names.inspect
    
    t = OMF::OML::OmlTable.new(:nmap_ping, schema)
    stream.on_new_tuple() do |v|
      r = v.to_a(false)
#     link_name = "#{v[:oml_sender]}::#{v[:dest_addr]}"
#     r.insert 0, LINKS[link_name] || "XXX - #{link_name}"
#     r.insert 0, link_name
      t.add_row(r)   
    end
    OMF::Web.register_datasource t 
  end
  
  def setup_table2(stream)
    schema = stream.schema.clone
#    schema.insert_column_at(0, :link)
    puts stream.schema.names.inspect

    u = OMF::OML::OmlTable.new(:nmap_port, schema)
    stream.on_new_tuple() do |v|
      r = v.to_a(false)
#     link_name = "#{v[:oml_sender]}::#{v[:dest_addr]}"
#     r.insert 0, LINKS[link_name] || "XXX - #{link_name}"
#     r.insert 0, link_name
      u.add_row(r)
    end
    OMF::Web.register_datasource u
  end

  def setup_table3(stream)
    schema = stream.schema.clone
#    schema.insert_column_at(0, :link)
    puts stream.schema.names.inspect

    w = OMF::OML::OmlTable.new(:nmap_service, schema)
    stream.on_new_tuple() do |v|
      r = v.to_a(false)
#     link_name = "#{v[:oml_sender]}::#{v[:dest_addr]}"
#     r.insert 0, LINKS[link_name] || "XXX - #{link_name}"
#     r.insert 0, link_name
      w.add_row(r)
    end
    OMF::Web.register_datasource w
  end

  def setup_table4(stream)
    schema = stream.schema.clone
#    schema.insert_column_at(0, :link)
    puts stream.schema.names.inspect

    x = OMF::OML::OmlTable.new(:nmap_os, schema)
    stream.on_new_tuple() do |v|
      r = v.to_a(false)
#     link_name = "#{v[:oml_sender]}::#{v[:dest_addr]}"
#     r.insert 0, LINKS[link_name] || "XXX - #{link_name}"
#     r.insert 0, link_name
      x.add_row(r)
    end
    OMF::Web.register_datasource x
  end

  def run
    ep = OMF::OML::OmlSqlSource.new(@db_name, :check_interval => 3.0)
    ep.on_new_stream() do |stream|
      info "Stream: #{stream.stream_name}"
      if stream.stream_name == 'nmap_ping'
        setup_table(stream)
      end
      if stream.stream_name == 'nmap_port'
        setup_table2(stream)
      end
      if stream.stream_name == 'nmap_service'
        setup_table3(stream)
      end
      if stream.stream_name == 'nmap_os'
        setup_table4(stream)
      end
    end
    ep.run    
    self
  end
  
end
wv = NmapDB.new("sqlite://#{File.dirname(__FILE__)}/db.sq3").run()
