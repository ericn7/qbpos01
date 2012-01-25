AppConfig = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]

require 'intuit'

$redis = Redis.new(:host => 'localhost', :port => 6379)
