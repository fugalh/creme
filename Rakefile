require 'rake/testtask'

task 'default' => 'test'
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test_*.rb']
  p t
  t.verbose = true
end

task 'install' do
  system 'ruby', 'setup.rb'
end
