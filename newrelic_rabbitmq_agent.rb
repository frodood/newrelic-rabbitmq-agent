require "rubygems"
require "bundler/setup"
require "newrelic_plugin"
require 'rabbitmq_manager'


module NewRelic
  module RabbitMQPlugin
    class Agent < NewRelic::Plugin::Agent::Base
      agent_guid 'com.redbubble.newrelic.plugin.rabbitmq'
      agent_version '1.0.0'
      agent_config_options :management_api_url, :server_name
      agent_human_labels('RabbitMQ') { server_name }
    
      def poll_cycle
        rmq_manager.queues.each do |queue|
          queue_name = queue['name'].split('queue.').last
          report_metric "Queue Size/#{queue_name}", 'messages', queue['messages'] 
        end
      end

      private
      def rmq_manager
        @rmq_manager ||= ::RabbitMQManager.new(management_api_url)
      end
    end

    NewRelic::Plugin::Setup.install_agent :rabbitmq, self
    NewRelic::Plugin::Run.setup_and_run
  end
end