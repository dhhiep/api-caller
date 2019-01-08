module Environment
  {
    'MODE' => 'dev',
    'DEV_BASE_URL_API' => 'https://api.trello.com/1/',
    'LIVE_BASE_URL_API' => 'https://api.trello.com/1/',
    'REQUEST_TIMEOUT' => '500',
    'DEBUG_MODE' => 'false',
    'API_KEY' => '',
    'API_TOKEN' => '',
    'GEMS_REQUIRES' => 'pry, httparty, colorize, awesome_print, net-ssh-telnet, benchmark-ips, hirb-unicode'
  }.each{ |k, v| ENV[k.upcase] ||= v }

  require_relative 'gem_requires.rb'
  require 'open-uri'
  require 'fileutils'
  require 'pry'
  require 'httparty'
  require 'benchmark'
  require 'awesome_print'
  require 'benchmark/ips'
  require_relative 'overrides.rb'
  require_relative 'helpers.rb'

  set_default_server!
end
