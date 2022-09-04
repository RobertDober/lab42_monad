require_relative "./lib/lab42/monad"
Gem::Specification.new do |s|
  s.name        = 'lab42_monad'
  s.version     = Lab42::Monad::VERSION
  s.date        = '2022-09-04'
  s.summary     = 'Simple Monadic Behaviors for Ruby'
  s.description = 'Implements only some simple monadic patterns right now, à la `IO.interact`'
  s.authors     = ['Robert Dober']
  s.email       = 'robert.dober@gmail.com'
  s.files       = Dir.glob('lib/lab42/**/*.rb')
  s.homepage    =
    'https://github.com/robertdober/lab42_monad'
  s.license     = 'Apache-2.0'

  s.required_ruby_version = '>= 3.1.0'
end
