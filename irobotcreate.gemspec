require File.expand_path("../lib/irobotcreate/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "irobotcreate"
  s.version     = IRobotCreate::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Peter Wagenet"]
  s.email       = ["peter.wagenet@gmail.com"]
  s.homepage    = "http://github.com/peterwagenet/irobotcreate"
  s.summary     = "Ruby interface for the IRobotCreate"
  s.description = "Connect to the IRobotCreate with Ruby via a serial connection."

  s.required_rubygems_version = ">= 1.3.6"

  # required for validation
  s.rubyforge_project         = "irobotcreate"

  s.add_dependency "serialport", "~> 1.0"

  s.files        = Dir["{lib}/**/*.rb", "examples/*.rb"]
  s.require_path = 'lib'
end