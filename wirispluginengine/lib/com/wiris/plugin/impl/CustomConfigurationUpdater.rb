module WirisPlugin
include  Wiris
require('com/wiris/plugin/api/ConfigurationKeys.rb')
require('com/wiris/plugin/configuration/ConfigurationUpdater.rb')
  class CustomConfigurationUpdater
  extend ConfigurationUpdaterInterface

  include Wiris

    attr_accessor :config
    def initialize(config)
      super()
      @config = config
    end
    def init(obj)
    end
    def updateConfiguration(ref_configuration)
      configuration = ref_configuration
      confClass = PropertiesTools::getProperty(configuration,ConfigurationKeys::CONFIGURATION_CLASS)
      if (confClass!=nil)&&(confClass::indexOf("com.wiris.plugin.servlets.configuration.ParameterServletConfigurationUpdater")!=-1)
        return 
      end
      if confClass!=nil
        cls = Type::resolveClass(confClass)
        if cls==nil
          raise Exception,("Class "+confClass)+" not found."
        end
        obj = Type::createInstance(cls,Array.new())
        if obj==nil
          raise Exception,("Instance from "+cls.to_s)+" cannot be created."
        end
        cu = (obj)
        @config::initialize_(cu)
        cu::updateConfiguration(configuration)
      end
    end
  end
end
