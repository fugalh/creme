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

task 'dist' do
  system 'hg','archive','-t','tbz2',"web/creme-#{`cat VERSION`.strip}.tar.bz2"
  system 'gem build gemspec; mv *.gem web/'
end
