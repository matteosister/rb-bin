require 'primarbbin'
require 'colorize'
require 'bunny'
require 'optparse'

class RabbitMQConsumer
  def initialize(argv)
    parse_argv argv
    log.call 'open a connection session with RabbitMQ'.light_green
    conn = Bunny.new(:host => 'rabbitmq')
    @rabbit_connector = RabbitConnector.new(conn, log)
    @ch = @rabbit_connector.open_channel
  end

  def execute!
    if @options[:queue_name].nil?
      declare_all_queues
    else
      queue_name = @options[:queue_name]
      q = declare_queue queue_name
      callback = callback queue_name
      log.call 'start listening for messages...'.green
      q.subscribe(:block => true, :manual_ack => true) do |delivery_info, properties, payload|
        puts delivery_info[:routing_key]
        puts "Received #{payload}, message properties are #{properties.inspect}. Calling #{callback}"
        @ch.acknowledge(delivery_info.delivery_tag)
      end
    end
  end

  def declare_all_queues
    conf_consumers.keys.map do |q|
      declare_queue q
    end
  end

  def declare_queue(name)
    @rabbit_connector.declare_queue(@ch, name, conf_consumers[name])
  end

  def conf_consumers
    YamlLoader.new(conf_file_name).consumers
  end

  def conf_file_name
    @options[:file_name]
  end

  def callback (queue_name)
    conf_consumers[queue_name]['callback']
  end

  # parse degli argomenti della command line
  def parse_argv(argv)
    # command line
    options = {}
    OptionParser.new do |opts|
      options[:queue_name] = nil
      opts.banner = "Usage: #{__FILE__} [options]"

      opts.on('-c', '--config CONFIG_FILE', 'config file') do |c|
        options[:file_name] = c
      end
      opts.on('-q', '--queue QUEUE', 'queue to be consumed') do |q|
        options[:queue_name] = q
      end
    end.parse!
    @options = options
  end

  # funzione generica di log
  def log
    lambda { |msg| puts '-- ' + msg }
  end

  # funzione generica di errore
  def err(msg)
    puts msg.red
    exit(1)
  end
end