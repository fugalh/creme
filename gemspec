require 'rubygems'
require 'rake'

SPEC = Gem::Specification.new do |s|
  s.name = 'creme'
  s.author = 'Hans Fugal'
  s.email = 'hans@fugal.net'
  s.version = `cat VERSION`.strip
  s.summary = 'Crème Rappel: the little reminder app with a silly French name.'
  s.files = FileList['lib/**/*.rb', 'bin/*', '[A-Z]*', 'test/**/*'].to_a
  s.executables << 'creme'
  s.test_files = Dir.glob('test/test_*.rb')
  s.homepage = 'http://hans.fugal.net/src/creme/'
end
