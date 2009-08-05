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
        
        # Wow. Just wow.
        # Who would've thought an API could be so bad?
        # Even as an *administrator* for an account there is no way
        # to get all the entries for all the users on a given day
        # at least, in a single request.
        #
        # Thus, this travesty of Ruby you see before you.
        # Firstly we gather the ids, and then have to make a request for every user.
        # Oh, did I mention that the Harvest API limits you to 40 requests every 15 seconds?
        #
        # Fuck.
        #
        # Whilst this is not important for small companies (such as ourselves), large
        # companies may run into issues.
        def find_all_by_day_and_year(day, year)
          entries = []
          Person.all.map(&:id).each do |id|
            entries += collection(Harvest.request("/daily/#{day}/#{year}?of_user=#{id}"))
          end
          entries
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