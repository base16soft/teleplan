require 'rubygems'
require 'bunny'
require 'json'
require 'settingslogic'
require 'openssl'
require_relative 'Teleplan/Settings'

class Teleplan


  def self.go!

    queue_name = 'telegram_q'
    exchange_name = 'telegram'

    log = Logger.new(STDOUT)
    if Settings.debug
      log.level = Logger::Severity::DEBUG
    else
      log.level = Logger::Severity::INFO
    end

    log.info 'starting application'

    conn = Bunny.new(keepalive: true, user: Settings.amqp_user, password: Settings.amqp_pass, host: Settings.amqp_server)
    conn.start

    log.debug 'created bunny connection'

    ch = conn.create_channel #ch.prefetch 1 # only one message at a time

    x = ch.fanout(exchange_name, :durable => true)
    q = ch.queue(queue_name, {:durable => true})
    q.bind(x)

    log.debug "created or obtained existed queue #{queue_name} and bind it to exchange #{exchange_name}"

    log.debug 'initial connect to telegram server...'
    Telegram.init(key: Settings.telegram_key,
                  log_file: Settings.logfile,
                  phone: '+79150731949')

    q.subscribe(:block => true, :ack => true) do |delivery_info, properties, payload|
      ack = lambda { ch.ack delivery_info[:delivery_tag], false }
      log.debug 'payload: ' + payload.inspect
      begin
        json = JSON.parse(payload)
      rescue JSON::ParserError => error
        log.error("error in parsing some message for json? : \n\n #{payload} \n\n so we just ignore it and delete message")
        ch.ack delivery_info.delivery_tag
        raise error
      end


      begin
        rcpt = json['to']
        data = json['body']

        rcpt = Telegram.contact_list.find { |user| user.phone == "#{rcpt_phone}" }
        Telegram.send_message(rcpt.to_peer, "#{data}")
      rescue IOError
        log.warn 'le troubles in sending: '
        sleep 5
        ch.basic_recover(true)
      else
        log.debug 'acknowledging message'
        ack.call
      end
    end

    puts 'Disconnecting...'

    conn.close
  end
end

