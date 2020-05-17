require "rake/testtask"
Rake::TestTask.new do |t|
  test_files = Dir['test/lib/**/*_test.rb']

  unless Gem.win_platform?
    test_files.push('test/connection_test.rb')
  end

  t.test_files = test_files
end

task :default => :test
