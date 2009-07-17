class Harvest
  module Resources
    class Entry < Harvest::Resource

      self.element_name = "entry"

      class << self

        def find(*arguments)
          original_arguments = arguments
          scope   = arguments.slice!(0)
          options = arguments.slice!(0) || {}
     
     
          # Hack!
          if scope == :all
            xml = Harvest.request("/daily")
            collection(xml)
          else
            # Go to daddy.
            super
          end
        end
        
        def find_all_by_day_and_year(day, year)
          xml = Harvest.request("/daily/#{day}/#{year}")
          collection(xml)
        end
        
        def create(request={})
          request[:project_id] = Project.request[:project]
          Net::HTTP.request_post(self.site + "/daily/add.xml")
        end

        def project_id=(id)
          @project_id = id
          self.site = self.site + "/projects/#{@project_id}"
        end

        def project_id
          @project_id
        end

        def person_id=(id)
          @person_id = id
          self.site = self.site + "/people/#{@person_id}"
        end

        def person_id
          @person_id
        end
        
        private
        
          def collection(xml)
            objects_for(xml.xpath("//day_entry"))
          end
        
        
      end
    end
  end
end