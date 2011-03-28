# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hangover/version"

Gem::Specification.new do |s|
  s.name        = "hangover"
  s.version     = Hangover::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Norman Timmler"]
  s.email       = ["norma.timmler@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Unlimited undo.}
  s.description = %q{Saves every change in a repositiory.}

  s.rubyforge_project = "hangover"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
