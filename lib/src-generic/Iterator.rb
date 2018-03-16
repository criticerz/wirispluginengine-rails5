module Wiris
    class Iterator < Enumerator
        def initialize(enum)
            super(enum)
        end
        alias enumeratornext next
        def next
            self.enumeratornext
        end

        def hasNext()
            begin
                self.peek
                return true
            rescue StopIteration
                return false
            end
        end
    end
end