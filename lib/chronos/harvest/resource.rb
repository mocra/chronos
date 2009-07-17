class Harvest
  # This is the base class from which all resource
  # classes for Harvest inherit. Site and authentication params
  # are loaded into this class when a Harvest::Base
  # object is initialized.
  class Resource < ActiveResource::Base
    
    class << self
      
      # Override this because AR does not have a configurable way to remove the .xml, which Harvest requires.
      def collection_path(prefix_options = {}, query_options = nil)
        prefix_options, query_options = split_options(prefix_options) if query_options.nil?
        "#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
      end
      
      # Override this because AR does not have a configurable way to remove the .xml, which Harvest requires.
      def element_path(id, prefix_options = {}, query_options = nil)
        prefix_options, query_options = split_options(prefix_options) if query_options.nil?
        "#{prefix(prefix_options)}#{collection_name}/#{id}#{query_string(query_options)}"
      end
      
      # There has been too many times where I've typed first.
      def first
        find(:first)
      end
      
      # There has been too many times where I've typed all.      
      def all
        find(:all)
      end
      def objects_for(xml_nodes)
        objects = []
        for object in xml_nodes
          objects << new(format.decode(object.to_s))
        end
        objects
      end
    end
  end
end