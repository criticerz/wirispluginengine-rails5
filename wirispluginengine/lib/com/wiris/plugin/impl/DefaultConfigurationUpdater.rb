module WirisPlugin
include  Wiris
require('com/wiris/util/sys/IniFile.rb')
require('com/wiris/plugin/configuration/ConfigurationUpdater.rb')
  class DefaultConfigurationUpdater
  extend ConfigurationUpdaterInterface

  include Wiris

    def initialize()
      super()
    end
    def init(obj)
    end
    def updateConfiguration(ref_configuration)
      configuration = ref_configuration
      s = Storage::newResourceStorage("default-configuration.ini")::read()
      defaultIniFile = IniFile::newIniFileFromString(s)
      h = defaultIniFile::getProperties()
      iter = h::keys()
      while iter::hasNext()
        key = iter::next()
        if PropertiesTools::getProperty(configuration,key)==nil
          PropertiesTools::setProperty(configuration,key,h::get(key))
        end
      end
    end
  end
end
