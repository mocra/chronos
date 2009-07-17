class Coop
  module Resources
    class Status < Coop::Resource
      
      class << self
        def find_all_by_group_id(group_id)
          statuses_xml = Coop.request("/groups/#{group_id}")
          statuses = []
        
          if statuses_xml
            status_collection = statuses_xml.xpath("//status")
            for status_xml in status_collection
              status = new(format.decode(status_xml.to_s))
              status.user = User.new(format.decode(status_xml.xpath("user").to_s))
              statuses << status
            end
          
            statuses
          else
            raise ActiveResource::ResourceNotFound, "Couldn't find statuses for group #{group_id}"
          
          end
        end
        
        # If the first argument is a time or a date, pretti-fy it first.
        # If the second argument is a string we'll leave it.
        def find_all_by_group_id_and_date(group_id, time_or_date_or_string) 
          date = time_or_date_or_string.strftime("%Y%m%d") if time_or_date_or_string.is_a?(Date) || time_or_date_or_string.is_a?(Time)
          statuses_xml = Coop.request("/groups/#{group_id}/#{date}")
          statuses = []
        
          if statuses_xml
            status_collection = statuses_xml.xpath("//status")
            for status_xml in status_collection
              status = new(format.decode(status_xml.to_s))
              status.user = User.new(format.decode(status_xml.xpath("user").to_s))
              statuses << status
            end
          
            statuses
          else
            raise ActiveResource::ResourceNotFound, "Couldn't find statuses for group #{group_id} on #{time_or_date}"
          
          end
        end
      end
    end
  end
end