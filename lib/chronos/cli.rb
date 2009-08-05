require 'optparse'

module Chronos
  class CLI
    def self.execute(stdout, arguments=[])

      # NOTE: the option -p/--path= is given as an example, and should be replaced in your application.

      options = {
        :path     => '~'
      }
      mandatory_options = %w(  )

      parser = OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /,'')
          This application is wonderful because...

          Usage: #{File.basename($0)} [options]

          Options are:
        BANNER
        opts.separator ""
        opts.on("-c", "--check", "Only check for running timers and exit.") { options[:check] = true }
        opts.on("-s server", "--server server", "Specify the server to connect to.") { |server| options[:server] = server }
        opts.on("-d", "--debug", "Print out debugging information.") { options[:debug] = true }
        
        opts.on("-h", "--help",
                "Show this help message.") { stdout.puts opts; exit }
        opts.parse!(arguments)

        if mandatory_options && mandatory_options.find { |option| options[option.to_sym].nil? }
          stdout.puts opts; exit
        end
      end

      path = options[:path]

      # do stuff
      Chronos::Bot.new(options)
    end
  end
end