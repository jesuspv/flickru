# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "flickru/version"

Gem::Specification.new do |s|
  s.name                  = "flickru"
  s.version               = Flickru::VERSION
  s.licenses              = ['MIT']
  s.authors               = ["Jesus Pardillo"]
  s.email                 = ["dev@jesuspardillo.com"]
  s.extra_rdoc_files      = ['README']
  s.homepage              = "http://github.com/jesuspv/flickru"
  s.summary               = %q{Command-line Flickr upload automator}
  s.description           = IO.read('README')
  s.files                 = `bash -c 'git ls-files -- {bin,lib,share}/* README'`.split("\n")
  s.test_files            = `bash -c 'git ls-files -- {spec,var}/* \
      | grep -v tc_accents | grep -v tc_whitespaces'` \
      .split("\n")
    # accents are escaped by git and not managed properly by rake
    # whitespaces are not properly managed by win32 gem install
  s.executables           = ['flickru', 'geowiki']
  s.require_paths         = ['lib']
  s.required_ruby_version = '>= 2.3'

  s.add_dependency "bundler", "~>1.13", ">=1.13.1"
  s.add_dependency "colorize", "~>0.8", ">=0.8.1"
  s.add_dependency "escape", "~>0.0", ">=0.0.4"
  s.add_dependency "exifr", "~>1.2", ">=1.2.5"
  s.add_dependency "flickraw-cached", "~>20120701"
  s.add_dependency "rubygems-update", "~>2.6", ">=2.6.7"
  s.add_development_dependency "rspec", "~>3.5", ">=3.5.0"
  s.add_development_dependency "simplecov", "~>0.12", ">=0.12.0"
  s.add_dependency "unicode_utils", "~>1.4", ">=1.4.0"
end
