require 'omf_web'
require 'omf_common/lobject'
require 'omf_oml/table'
require 'omf_oml/sql_source'


class T50DB < OMF::Common::LObject
  
#  LINKS = {'Source1' => 'link 1',
#          }
  
  def initialize(db_name)
    @db_name = db_name
  end
  
  def setup_table(stream)
    schema = stream.schema.clone
#    schema.insert_column_at(0, :link)
    puts stream.schema.names.inspect
    
    t = OMF::OML::OmlTable.new(:t50, schema)
    stream.on_new_tuple() do |v|
      r = v.to_a(false)
#     link_name = "#{v[:oml_sender]}::#{v[:dest_addr]}"
#     r.insert 0, LINKS[link_name] || "XXX - #{link_name}"
#     r.insert 0, link_name
      t.add_row(r)   
    end
    OMF::Web.register_datasource t 
  end
  
  def run
    ep = OMF::OML::OmlSqlSource.new(@db_name, :check_interval => 3.0)
    ep.on_new_stream() do |stream|
      info "Stream: #{stream.stream_name}"
      if stream.stream_name == 't50_t50'
        setup_table(stream)
      end
    end
    ep.run    
    self
  end
  
end
wv = T50DB.new("sqlite://#{File.dirname(__FILE__)}/db.sq3").run()
