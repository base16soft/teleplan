Gem::Specification.new do |s|
  s.name = 'teleplan'
  s.version = '0.0.1'
  s.date = '2014-06-26'
  s.summary = 'Telegram via RabbitMQ proxy.'
  s.description = 'Telegram takes encrypted json messages from rabbitmq query and push it to telegram connection'
  s.homepage = 'http://github.com/uu/teleplan'
  s.authors = ['Michael Pirogov']
  s.email = 'uu@megaplan.ru'
  s.files = Dir['lib/**/*'] + Dir['bin/*']

  s.add_dependency('bunny', '>= 1.3.0')
  s.add_dependency('settingslogic', '>= 2.0.6')

  s.executables << 'teleplan'

end
