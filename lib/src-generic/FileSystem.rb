module Wiris
	class FileSystem
		def self.readDirectory(folder)
			return Dir::entries(folder) - ['.'] - ['..']
		end

		def self.createDirectory(folder)
			Dir.mkdir(folder)
		end

		def self.exists(folder)
			File.exists?(folder)
		end

		def self.fullPath(path)
			if !exists(path)
				return nil
			end
			return File::realpath(path)
		end
		def self.rename (path, newpath)
			File::rename(path, newpath)
			raise Exception, "Unable to rename \""+path+"\" to \""+newpath+"\"."
		end
		def self.isDirectory(path)
			return File.directory?(path)
		end
		def self.deleteDirectory(folder)
			if (Dir.entries(folder) == ['.', '..'])
				return Dir.delete(folder)
			end
		end
		def self.deleteFile(file)
			return File.delete(file)
		end
	end
end
