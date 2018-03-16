module WirisPlugin
include  Wiris
require('com/wiris/plugin/api/ConfigurationKeys.rb')
require('com/wiris/util/sys/Store.rb')
require('com/wiris/plugin/storage/StorageAndCache.rb')
  class FileStorageAndCache
  extend StorageAndCacheInterface

  include Wiris

    attr_accessor :config
    def initialize()
      super()
    end
    def init(obj,config)
      @config = config
    end
    def codeDigest(content)
      formula = getAndCheckFolder(ConfigurationKeys::FORMULA_FOLDER)
      digest = Md5Tools::encodeString(content)
      store = Store::newStoreWithParent(Store::newStore(formula),digest+".ini")
      store::write(content)
      return digest
    end
    def decodeDigest(digest)
      formula = getAndCheckFolder(ConfigurationKeys::FORMULA_FOLDER)
      store = Store::newStoreWithParent(Store::newStore(formula),digest+".ini")
      return store::read()
    end
    def retreiveData(digest,service)
      formula = getAndCheckFolder(ConfigurationKeys::CACHE_FOLDER)
      store = Store::newStoreWithParent(Store::newStore(formula),digest+getExtension(service))
      if !store::exists()
        return nil
      end
      return store::readBinary()::getData()
    end
    def storeData(digest,service,stream)
      formula = getAndCheckFolder(ConfigurationKeys::CACHE_FOLDER)
      store = Store::newStoreWithParent(Store::newStore(formula),digest+getExtension(service))
      store::writeBinary(Bytes::ofData(stream))
    end
    def getAndCheckFolder(key)
      folder = PropertiesTools::getProperty(@config,key)
      if (folder==nil)||(folder::trim()::length()==0)
        raise Exception,"Missing configuration value: "+key
      end
      return folder
    end
    def getExtension(service)
      if (service=="png")
        return ".png"
      end
      return ("."+service)+".txt"
    end
    def deleteCache()
    end
  end
end
