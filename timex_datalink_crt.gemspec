# frozen_string_literal: true

require_relative "lib/timex_datalink_crt/version.rb"

Gem::Specification.new do |s|
  s.name        = "timex_datalink_crt"
  s.version     = TimexDatalinkCrt::VERSION
  s.summary     = "Write data to Timex Datalink devices with an optical sensor using a CRT monitor"
  s.authors     = ["Maxwell Pray"]
  s.email       = "synthead@gmail.com"
  s.homepage    = "https://github.com/synthead/timex_datalink_crt/tree/v#{s.version}"
  s.license     = "MIT"

  s.files       = [
    "lib/timex_datalink_crt.rb",
    "lib/timex_datalink_crt/version.rb"
  ]

  s.add_dependency "ruby-sdl2", "~> 0.3.5"
  s.add_dependency "timex_datalink_client", "~> 0.12.1"
end
