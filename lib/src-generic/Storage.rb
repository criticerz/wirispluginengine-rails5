module Wiris
	class Storage
		TYPE_FILE = 0;
		TYPE_RESOURCE = 1;
		TYPE_URL =2;
		@cls = nil
		@@resourcesDir = nil

		def type=(type)
			@type = type
		end
		def type
			@type
		end
		def file=(file)
			@file = file
		end
		def file
			@file
		end
		def resourceName
			@resourceName
		end
		def resourceName=(resourceName)
			@resourceName = resourceName
		end

		def location
			@location
		end

		def location=(location)
			@location = location
		end

		def self.resourcesDir=(resourcesDir)
			@@resourcesDir = resourcesDir
		end
		def self.resourcesDir
			@@resourcesDir
		end

		def initialize(location=nil)
			if location != nil
				@location = location
			end
		end

		def self.newStorage(name)
			s = Storage.new(name)
			s.type = TYPE_FILE
			return s
		end

		def self.newStorageWithParent(parent, name)
	        s = Storage.new(parent.location)
	        s.type = parent.type;
	        if (parent.type == TYPE_FILE)
	            # @file = File.new(File.join(parent.location, name), "w+")
	            # @file.close
	            s.location = File.join(parent.location, name)
	        elsif (parent.type == TYPE_RESOURCE)
	            s.resourceName = parent.resourceName;
	            if (s.resourceName.length() > 0 && !s.resourceName.endsWith("/")) 
	                s.resourceName += "/"
	            end
	            s.resourceName += name
	        elsif (parent.type == TYPE_URL)
	            url = Url.new(Url.new(parent.url),name).toExternalForm()
	        end
	        return s
	    end

		def self.newResourceStorage(name)
			s = Storage.new(File.join(getResourcesDir,name))
			s.type = TYPE_RESOURCE
			return s;
		end

		def read()
			return File.read(location)
		end

		def readBinary()		
			s = File.binread(location)
			return s.bytes.to_a
		end

		def write(str)
			writeOrAppend(str, false)
		end

		def writeBinary(bs)
			File.open(location, 'wb' ) do |output|
	  			output.write bs.pack("C*")
	  		end
		end

		def writeOrAppend(str, append)
			if (@type == TYPE_RESOURCE)
				notImplemented()
			end
			if (@type == TYPE_URL)
				notImplemented()
			end
			@file = File.new(@location, "w")
			@file.write(str)
			@file.close
		end

		def exists()
			return File.exists?(location)
		end

		def mkdirs()
	        if (@type == TYPE_RESOURCE)
	            notImplemented()
	        end
	        if (@type == TYPE_URL)
	            notImplemented()
	        end        
	        Dir.mkdir(@location)
	        
		end

		def self.getResourcesDir()
			if @@resourcesDir.nil?
				setResourcesDir()
			end
			return @@resourcesDir
		end

		def self.setResourcesDir()
			@@resourcesDir = File.dirname(__FILE__)
		end

		def notImplemented()
			 raise Exception,'Error: Operation not available on this Storage'
		end

		def toString()
			if type == TYPE_FILE
				return location.to_s
			elsif type == TYPE_RESOURCE
				return resourceName
			elsif type == TYPE_URL
				return url
			else
				return nil
			end
		end
	end
end