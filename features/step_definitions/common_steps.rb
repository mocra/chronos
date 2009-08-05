Given /^I am about to (\w+) (\w+) for (\w+[\/?\w+?]{1,})$/ do |method, service, things|
  url = "http#{'s' if @ssl}://test%40test.com:password@#{@subdomain + '.' if @subdomain}#{Services[service.downcase.to_sym]}/#{things}"
  # puts "Registering: #{method.upcase} #{url}"
  # puts fixture_path("#{things}.xml").inspect 
  FakeWeb.register_uri(method.to_sym, url, :body => fixture_path("#{things}.xml"))
end

Given /^I am logged in to (.*?) at (.*?)$/ do |subdomain, service|
  standard = { :email => "test@test.com", :password => "password" }
  @service = if service == "Harvest"
    
    # For later on, when we fake the web
    @subdomain = subdomain
    
    send(service, standard.merge(:subdomain => @subdomain))
  else
    send(service, standard)
  end
end

Given /^time is frozen$/ do
  time = "16-07-2009".to_time
  Time.stubs(:now).returns(time)
end

When /^I ask (\w+) for all (\w+)$/ do |service, things|
  @objects = @service.send(things).find(:all)
  @output = @objects.map(&:attributes).inspect
end

When /^I ask (\w+) for the first (\w+)$/ do |service, thing|
  @object = @service.send(thing.pluralize).find(1)
  @output = @object.attributes
end

Then /^the (\w+) should be '(.*?)'$/ do |field, value|
  @object.send(field).should eql(value)
end

Then /^the (\w+) of the first element should be (.*?)$/ do |field, value|
  @objects.first.send(field).should eql(value)
end

Then /^I should be given a (.*?) (.*?)$/ do |service, resource|
  @object.is_a?(eval("#{service}::Resources::#{resource}")).should be_true
end

Given /^this project is active project folder/ do
  @active_project_folder = File.expand_path(File.dirname(__FILE__) + "/../..")
end

Given /^env variable \$([\w_]+) set to "(.*)"/ do |env_var, value|
  ENV[env_var] = value
end

Given /"(.*)" folder is deleted/ do |folder|
  in_project_folder { FileUtils.rm_rf folder }
end

When /^I invoke "(.*)" generator with arguments "(.*)"$/ do |generator, arguments|
  @stdout = StringIO.new
  in_project_folder do
    if Object.const_defined?("APP_ROOT")
      APP_ROOT.replace(FileUtils.pwd)
    else 
      APP_ROOT = FileUtils.pwd
    end
    run_generator(generator, arguments.split(' '), SOURCES, :stdout => @stdout)
  end
  File.open(File.join(@tmp_root, "generator.out"), "w") do |f|
    @stdout.rewind
    f << @stdout.read
  end
end

When /^I run executable "(.*)" with arguments "(.*)"/ do |executable, arguments|
  @stdout = File.expand_path(File.join(@tmp_root, "executable.out"))
  in_project_folder do
    system "#{executable} #{arguments} > #{@stdout} 2> #{@stdout}"
  end
end

When /^I run project executable "(.*)" with arguments "(.*)"/ do |executable, arguments|
  @stdout = File.expand_path(File.join(@tmp_root, "executable.out"))
  in_project_folder do
    system "ruby #{executable} #{arguments} > #{@stdout} 2> #{@stdout}"
  end
end

When /^I run local executable "(.*)" with arguments "(.*)"/ do |executable, arguments|
  @stdout = File.expand_path(File.join(@tmp_root, "executable.out"))
  executable = File.expand_path(File.join(File.dirname(__FILE__), "/../../bin", executable))
  in_project_folder do
    @client_pid =  Kernel.fork { system "ruby #{executable} #{arguments} > #{@stdout} 2> #{@stdout}" }
    # Let it run for 15 seconds... and then we kill it.
    sleep(30)
    Process.kill("TERM", @client_pid)
  end
end

When /^I invoke task "rake (.*)"/ do |task|
  @stdout = File.expand_path(File.join(@tmp_root, "tests.out"))
  in_project_folder do
    system "rake #{task} --trace > #{@stdout} 2> #{@stdout}"
  end
end

Then /^folder "(.*)" (is|is not) created/ do |folder, is|
  in_project_folder do
    File.exists?(folder).should(is == 'is' ? be_true : be_false)
  end
end

Then /^file "(.*)" (is|is not) created/ do |file, is|
  in_project_folder do
    File.exists?(file).should(is == 'is' ? be_true : be_false)
  end
end

Then /^file with name matching "(.*)" is created/ do |pattern|
  in_project_folder do
    Dir[pattern].should_not be_empty
  end
end

Then /^file "(.*)" contents (does|does not) match \/(.*)\// do |file, does, regex|
  in_project_folder do
    actual_output = File.read(file)
    (does == 'does') ?
      actual_output.should(match(/#{regex}/)) :
      actual_output.should_not(match(/#{regex}/))
  end
end

Then /gem file "(.*)" and generated file "(.*)" should be the same/ do |gem_file, project_file|
  File.exists?(gem_file).should be_true
  File.exists?(project_file).should be_true
  gem_file_contents = File.read(File.dirname(__FILE__) + "/../../#{gem_file}")
  project_file_contents = File.read(File.join(@active_project_folder, project_file))
  project_file_contents.should == gem_file_contents
end

Then /^(does|does not) invoke generator "(.*)"$/ do |does_invoke, generator|
  actual_output = File.read(@stdout)
  does_invoke == "does" ?
    actual_output.should(match(/dependency\s+#{generator}/)) :
    actual_output.should_not(match(/dependency\s+#{generator}/))
end

Then /I should see help option "(.*)"/ do |opt|
  actual_output = File.read(@stdout)
  actual_output.should match(/#{opt}/)
end

Then /^I should see$/ do |text|
  actual_output = File.read(@stdout)
  actual_output.should contain(text)
end

Then /^I should not see$/ do |text|
  actual_output = File.read(@stdout)
  actual_output.should_not contain(text)
end

Then /^I should see exactly$/ do |text|
  actual_output = File.read(@stdout)
  actual_output.should == text
end

Then /^I should see all (\d+) tests pass/ do |expected_test_count|
  expected = %r{^#{expected_test_count} tests, \d+ assertions, 0 failures, 0 errors}
  actual_output = File.read(@stdout)
  actual_output.should match(expected)
end

Then /^I should see all (\d+) examples pass/ do |expected_test_count|
  expected = %r{^#{expected_test_count} examples?, 0 failures}
  actual_output = File.read(@stdout)
  actual_output.should match(expected)
end

Then /^yaml file "(.*)" contains (\{.*\})/ do |file, yaml|
  in_project_folder do
    yaml = eval yaml
    YAML.load(File.read(file)).should == yaml
  end
end

Then /^Rakefile can display tasks successfully/ do
  @stdout = File.expand_path(File.join(@tmp_root, "rakefile.out"))
  in_project_folder do
    system "rake -T > #{@stdout} 2> #{@stdout}"
  end
  actual_output = File.read(@stdout)
  actual_output.should match(/^rake\s+\w+\s+#\s.*/)
end

Then /^task "rake (.*)" is executed successfully/ do |task|
  @stdout.should_not be_nil
  actual_output = File.read(@stdout)
  actual_output.should_not match(/^Don't know how to build task '#{task}'/)
  actual_output.should_not match(/Error/i)
end

Then /^gem spec key "(.*)" contains \/(.*)\// do |key, regex|
  in_project_folder do
    gem_file = Dir["pkg/*.gem"].first
    gem_spec = Gem::Specification.from_yaml(`gem spec #{gem_file}`)
    spec_value = gem_spec.send(key.to_sym)
    spec_value.to_s.should match(/#{regex}/)
  end
end

Then /^the bot dies$/ do
  # TODO: Work out why it doesn't kill these processes.
  Process.kill("TERM", @client_pid + 1)
  Process.kill("TERM", @client_pid + 2)
end


