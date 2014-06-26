require 'settingslogic'
class Settings < Settingslogic
  source Gem::default_path[-1] + "/gems/teleplan-9999/lib/Teleplan/settings/application.yml"
end
