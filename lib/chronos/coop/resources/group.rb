class Coop
  module Resources
    class Group < Coop::Resource
      
      class << self
      
        def find(*arguments)
          original_arguments = arguments
          scope   = arguments.slice!(0)
          options = arguments.slice!(0) || {}
        

          # Go to daddy.
          if scope == :all || scope == :first || scope == :last
            super(*[scope, options])
          # Hack!
          else
            groups_xml = Coop.request("/groups")
            group_xml = groups_xml.xpath("//group[id='#{scope}']").to_s
            if group_xml
              group = new(format.decode(group_xml).merge(:id => scope))
              group.statuses = Status.find_all_by_group_id(scope)
            
              group
            else
              raise ActiveResource::ResourceNotFound, "could not find group with group #{id}"
            end
          end
        end
        
        # Yes, this is like the above method. Couldn't figure out how to make it prettier.
        # Go for it.
        def find_by_id_and_date(id, time_or_date)
          groups_xml = Coop.request("/groups")
          group_xml = groups_xml.xpath("//group[id='#{id}']").to_s
          if group_xml
            group = new(format.decode(group_xml).merge(:id => id))
            group.statuses = Status.find_all_by_group_id_and_date(id, time_or_date)
          
            group
          else
            raise ActiveResource::ResourceNotFound, "could not find group with group #{id}"
          end
        end
      end
    end
  end
end