require 'fileutils'
require './update_ddns'
task :install do
    FileUtils.copy 'update_ddns.rb', '/usr/local/bin/update_ddns'
end

task :init_config do
    Dir.mkdir $confhome unless Dir.exists? $confhome
    unless File.exists? $config
        config = {'api': {}}
        print "API Token ID: "
        config['api']['id'] = gets.strip
        print "API Token: "
        config['api']['token'] = gets.strip
        print "Domain: "
        config['domain'] = gets.strip
        print "Sub Domain(www or @, @ for default): "
        config['domain'] = (gets || "@").strip
        print "The original value of the record you want to update: "
        config['init_record_vale'] = (gets || "@").strip
    end
end


