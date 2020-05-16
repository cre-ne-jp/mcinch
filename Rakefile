require "rake/testtask"
Rake::TestTask.new do |t|
  t.test_files = Dir[
    'test/lib/**/*_test.rb',
    'test/*_test.rb'
  ]
end

task :default => :test
