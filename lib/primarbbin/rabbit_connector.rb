class RabbitConnector
  attr_accessor :conn, :ch

  def initialize(conn, logger)
    @conn = conn
    @logger = logger
  end

  def open_channel
    @logger.call 'start RabbitMQ connection'.light_green
    @conn.start
    @logger.call 'creating RabbitMQ channel'.light_green
    @conn.create_channel
  end

  def declare_queue(ch, queue_name, conf)
    exchange_options = conf['exchange_options']
    routing_keys = conf['queue_options']['routing_keys']
    callback = conf['callback']

    exchange = ch.topic(exchange_options['name'])
    @logger.call "exchange #{exchange_options['name']} declared".light_red

    args = conf['queue_options']['arguments']
    new_args = {}
    args.keys.map { |key|
      new_args[key] = args[key][1]
    }
    queue_args = {}
    queue_args[:durable] = true
    queue_args[:arguments] = new_args
    q = ch.queue(queue_name, queue_args)
    @logger.call "queue #{queue_name} declared".green

    routing_keys.each { |rk|
      ch.queue(queue_name).bind(exchange, :routing_key => rk)
      @logger.call ' - binding with routing key ' + "#{rk}".light_blue
    }
    q
  end
end