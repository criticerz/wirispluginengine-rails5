module WirisPlugin
include  Wiris
require('com/wiris/plugin/api/ConfigurationKeys.rb')
require('com/wiris/plugin/api/ParamsProvider.rb')
  class GenericParamsProviderImpl
  extend ParamsProviderInterface

  include Wiris

    attr_accessor :properties
    def initialize(properties)
      super()
      @properties = properties
    end
    def getParameter(param,dflt)
      return PropertiesTools::getProperty(@properties,param,dflt)
    end
    def getRequiredParameter(param)
      parameter = PropertiesTools::getProperty(@properties,param,nil)
      if parameter!=nil
        return parameter
      else 
        raise Exception,("Error: parameter"+param)+"is required"
      end
    end
    def getParameters()
      return @properties
    end
    def getRenderParameters(configuration)
      renderParams = PropertiesTools::newProperties()
      renderParameterList = configuration::getProperty(ConfigurationKeys::EDITOR_PARAMETERS_LIST,ConfigurationKeys::EDITOR_PARAMETERS_DEFAULT_LIST)::split(",")
        for i in 0..renderParameterList::length-1
          key = renderParameterList[i]
          value = PropertiesTools::getProperty(@properties,key)
          if value!=nil
            PropertiesTools::setProperty(renderParams,key,value)
          end
          i+=1
        end
      return renderParams
    end
    def getServiceParameters()
      serviceParams = PropertiesTools::newProperties()
      serviceParamListArray = Std::split(ConfigurationKeys::SERVICES_PARAMETERS_LIST,",")
        for i in 0..serviceParamListArray::length()-1
          key = serviceParamListArray::_(i)
          value = PropertiesTools::getProperty(@properties,key)
          if value!=nil
            PropertiesTools::setProperty(serviceParams,key,value)
          end
          i+=1
        end
      return serviceParams
    end
  end
end
