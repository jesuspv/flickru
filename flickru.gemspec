# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "flickru/version"

Gem::Specification.new do |s|
  s.name        = "flickru"
  s.version     = Flickru::VERSION
  s.authors     = ["Jesús Pardillo"]
  s.email       = ["dev@jesuspardillo.com"]
  s.homepage    = "http://rubygems.org/gems/flickru"
  s.summary     = %q{Command-line Flickr Upload Automator}
  s.description = IO.read('README')
  s.files         = `git ls-files -- {bin,lib}/*`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = ['flickru']
  s.require_paths = ['lib']

  s.add_dependency "colorize", "~>0.5.8"
  s.add_dependency "escape", "~>0.0.4"
  s.add_dependency "flickraw", "~>0.9.4"
  s.add_dependency "rubygems-update", "~>1.8.11"
  s.add_dependency "simplecov", "~>0.5.4"
  s.add_dependency "unicode_utils", "~>1.1.2"
  s.add_development_dependency "rspec", "~>2.7.0"
end
