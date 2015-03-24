# coding: utf-8

ENV['RACK_ENV'] = 'rest_api_test'

require 'singleton'
require 'fileutils'
require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

module Jiji
  class Server

    include Singleton

    def initilize
      @running = false
    end

    def setup
      return if @running

      initialize_db
      pid = start_server
      register_shutdown_fook(pid)

      @running = true
    end

    private

    def initialize_db
      Jiji::Test::DataBuilder.new.clean
    end

    def start_server
      log_dir = File.join(BUILD_DIR, 'rest_spec')
      FileUtils.mkdir_p log_dir
      pid = spawn(
        { 'RACK_ENV' => 'rest_api_test' },
        'bundle exec puma -C config/puma.rb',
        out: File.join(log_dir, 'test-server.log'), err: :out)
      puts "start server pid=#{pid}"
      sleep 10
      pid
    end

    def register_shutdown_fook(pid)
      at_exit do
        fail "failed to kill server. pid=#{pid}" unless system("kill #{pid}")
        puts "stop server pid=#{pid}"
      end
    end

  end
end
