#!/usr/bin/env ruby
#encoding=utf-8
require 'socket'
require 'yaml'
require 'json'
require 'rest-client'
class DNSPodUpdater
    DNSPodError = Class.new StandardError
    def initialize(config_file, cache_file)
        @config = YAML.load_file config_file
        @cache_file = cache_file
        @cache = File.exists?(cache_file) ? YAML.load_file(cache_file) : {}
    end
    def save_cache
        File.write @cache_file, @cache.to_yaml
    end
    def get_form(args = {})
        {
            login_token: @config['api']['id']<<","<<@config['api']['token'],
            format: 'json',
            lang: 'en',
            error_on_empty: 'yes',
        }.merge(args)
    end
    def post(url, form={})
        res = JSON.parse RestClient.post(url, get_form(form)).body
        raise DNSPodError.new(res['status']['message']) unless res['status']['code']=='1'
        res
    end
    def update_dyn_dns
        new_ip = get_ip
        if new_ip == @cache['ip']
            puts "Ignored"
            return nil
        end
        if @cache.empty?
            record = get_record
            record_id = @cache['record_id'] = record['id']
        else
            record_id = @cache['record_id']
        end
        res = post('https://dnsapi.cn/Record.Ddns',
            domain: @config['domain'],
            record_id: record_id,
            sub_domain: @config['sub_domain'],
            record_line: '默认',
            value: new_ip,
        )
        @cache['ip'] = new_ip
        save_cache
        res
    end
    def get_record
        post("https://dnsapi.cn/Record.List",
            domain: @config['domain'],
            sub_domain: @config['sub_domain'],
            record_type: 'A',
            record_line: '默认',
            value: @cache['ip'] || @config['init_record_vale'],
        )['records'].detect{|r| r['type'] == 'A'}
    end
    def get_ip
        sock = TCPSocket.new 'ns1.dnspod.net', 6666
        ip = sock.recv(16)
        sock.close()
        ip
    end
end

if __FILE__ == $0
    u = DNSPodUpdater.new('config.yaml', 'cache.yaml')
    res = u.update_dyn_dns
    puts "Succeed" unless res.nil?
end
