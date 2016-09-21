#!/usr/bin/env ruby
#encoding=utf-8
require './update_ddns'

u = DNSPodUpdater.new('config.yaml', 'cache.yaml')
puts u.update_dyn_dns
