module Similar
  # Class method to load all ruby files from a given path.
  def self.load_all_ruby_files_from_path(path)
    files = Dir["#{path}/*"]
    files.each { |f| require f }
  end 
  
  def self.included(klass)
    klass.class_eval do |k|
      def self.request(path)
        http = Net::HTTP.new("#{self.subdomain + '.' if self.subdomain }#{self.api_domain}", 80)
        http.start do |http|
          req = Net::HTTP::Get.new(path, { "Accept" => "application/xml", "Content-Type" => "application/xml"})
          req.basic_auth(email, password)
          # TODO: Add 404 checking and what not.
          Nokogiri::XML(http.request(req).body)
        end
      end
    end
  end
end