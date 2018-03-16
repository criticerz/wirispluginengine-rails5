module WirisPlugin
include  Wiris
require('com/wiris/plugin/api/ConfigurationKeys.rb')
require('com/wiris/util/sys/Store.rb')
require('com/wiris/plugin/storage/StorageAndCache.rb')
  class FolderTreeStorageAndCache
  extend StorageAndCacheInterface

  include Wiris

    attr_accessor :config
  @@backwards_compat = true
    def self.backwards_compat
      @@backwards_compat
    end
    def self.backwards_compat=(backwards_compat)
      @@backwards_compat = backwards_compat
    end
    def initialize()
      super()
    end
    def init(obj,config)
      @config = config
    end
    def codeDigest(content)
      digest = Md5Tools::encodeString(content)
      parent = getFolderStore(getAndCheckFolder(ConfigurationKeys::FORMULA_FOLDER),digest)
      parent::mkdirs()
      store = getFileStoreWithParent(parent,digest,"ini")
      store::write(content)
      return digest
    end
    def decodeDigest(digest)
      formula = getAndCheckFolder(ConfigurationKeys::FORMULA_FOLDER)
      store = getFileStore(formula,digest,"ini")
      if @@backwards_compat
        if !store::exists()
          oldstore = Store::newStore(((formula+"/")+digest)+".ini")
          parent = store::getParent()
          parent::mkdirs()
          oldstore::moveTo(store)
        end
      end
      return store::read()
    end
    def retreiveData(digest,service)
      formula = getAndCheckFolder(ConfigurationKeys::CACHE_FOLDER)
      store = getFileStore(formula,digest,getExtension(service))
      if @@backwards_compat
        if !store::exists()
          oldstore = Store::newStore((((formula+"/")+digest)+".")+getExtension(service))
          if !oldstore::exists()
            return nil
          end
          parent = store::getParent()
          parent::mkdirs()
          oldstore::moveTo(store)
        end
      else 
        if !store::exists()
          return nil
        end
      end
      return store::readBinary()::getData()
    end
    def storeData(digest,service,stream)
      formula = getAndCheckFolder(ConfigurationKeys::CACHE_FOLDER)
      parent = getFolderStore(formula,digest)
      parent::mkdirs()
      store = getFileStoreWithParent(parent,digest,getExtension(service))
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
        return "png"
      end
      if (service=="svg")
        return "svg"
      end
      return service+".txt"
    end
    def getFolderStore(dir,digest)
      return Store::newStore((((dir+"/")+Std::substr(digest,0,2).to_s)+"/")+Std::substr(digest,2,2).to_s)
    end
    def getFileStoreWithParent(parent,digest,extension)
      return Store::newStoreWithParent(parent,(Std::substr(digest,4).to_s+".")+extension)
    end
    def getFileStore(dir,digest,extension)
      return getFileStoreWithParent(getFolderStore(dir,digest),digest,extension)
    end
    def updateFoldersStructure()
      updateFolderStructure(getAndCheckFolder(ConfigurationKeys::CACHE_FOLDER))
      updateFolderStructure(getAndCheckFolder(ConfigurationKeys::FORMULA_FOLDER))
    end
    def updateFolderStructure(dir)
      folder = Store::newStore(dir)
      files = folder::list()
      if files!=nil
          for i in 0..files::length-1
            digest = isFormulaFileName(files[i])
            if digest!=nil
              newFolder = getFolderStore(dir,digest)
              newFolder::mkdirs()
              newFile = getFileStoreWithParent(newFolder,digest,Std::substr(files[i],files[i]::indexOf(".")+1))
              file = Store::newStoreWithParent(folder,files[i])
              file::moveTo(newFile)
            end
            i+=1
          end
      end
    end
    def isFormulaFileName(name)
      i = name::indexOf(".")
      if i==-1
        return nil
      end
      digest = Std::substr(name,0,i)
      if digest::length()!=32
        return nil
      end
      return digest
    end
    def deleteCache()
      formulaFolder = getAndCheckFolder(ConfigurationKeys::FORMULA_FOLDER)
      cacheFolder = getAndCheckFolder(ConfigurationKeys::CACHE_FOLDER)
      includes = Array.new()
      includes::push("png")
      includes::push("csv")
      includes::push("txt")
      if !(PropertiesTools::getProperty(@config,ConfigurationKeys::SAVE_MODE,"xml")=="image")
        includes::push("ini")
      end
      Store::deleteDirectory(formulaFolder,includes)
      Store::deleteDirectory(cacheFolder,includes)
    end
  end
end
