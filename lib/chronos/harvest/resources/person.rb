class Harvest
  module Resources
    class Person < Harvest::Resource
      include Chronos::Plugins::Toggleable
      
      # Find all entries for the given person;
      # options[:from] and options[:to] are required;
      # include options[:user_id] to limit by a specific project.
      def entries(options={})
        validate_options(options)
        entry_class = Harvest::Resources::Entry.clone
        entry_class.person_id = self.id
        entry_class.find :all, :params => format_params(options)
      end
      
      def expenses(options={})
        validate_options(options)
        expense_class = Harvest::Resources::Expense.clone
        expense_class.person_id = self.id
        expense_class.find :all, :params => format_params(options)
      end
      
      def name
        "#{first_name} #{last_name}"
      end
      
      class << self

        def without_running_timers
          todays_entries = Entry.find_all_by_day_and_year(Time.now.yday, Time.now.year)
          
          well_behaved_user_ids = todays_entries.map(&:user_id).uniq
          find(:all).delete_if { |u| !u.is_active || well_behaved_user_ids.include?(u.id) }
        end
        
        def find_by_email(email)
          all.detect { |u| u.email == email }
        end
      end
      
      private
      
        def validate_options(options)
          if [:from, :to].any? {|key| !options[key].respond_to?(:strftime) }
            raise ArgumentError, "Must specify :from and :to as dates."
          end
          
          if options[:from] > options[:to]
            raise ArgumentError, ":start must precede :end."
          end
        
        end
        def format_params(options)
          ops = { :from => options[:from].strftime("%Y%m%d"),
                  :to   => options[:to].strftime("%Y%m%d")}
          ops[:project_id] = options[:project_id] if options[:project_id]
          return ops
        end
      
    end
  end
end