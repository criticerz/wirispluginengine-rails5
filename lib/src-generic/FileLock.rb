module Wiris
    class FileLock

        TIMEOUT= 5000
        WAIT = 100

        def file
            @file
        end

        def initialize(file)
            @file = file
        end

        def self.getLock(filename, remaining = 0)
            # Time in milliseconds
            starwait = (Time.now.to_f*1000).to_i
            file = File.new(filename + ".lock", "w+")
            return FileLock.new(file)
        end

        def release()
            file.close
            File.delete(file)
        end
    end
end