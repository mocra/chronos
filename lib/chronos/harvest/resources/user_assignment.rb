# This class is accessed by an instance of Project.
class Harvest
  module Resources
    class UserAssignment < Harvest::Resource
            
      self.element_name = "user_assignment"
      
      class << self
        
        def project_id=(id)
          @project_id = id
          set_site
        end
        
        def project_id
          @project_id
        end
        
        def set_site
          self.site = self.site + "/projects/#{self.project_id}"
        end
        
      end
      
    end
  end
end