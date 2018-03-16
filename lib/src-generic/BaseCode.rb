module Wiris
    class BaseCode
    	@bytes
    	@nbits
        @tbl = nil
        @charSet
        @base

    	def initialize(base)
    		@base = base
            @charSet = base.toString()
            n = base.length()
            @nbits = 0
            while(n>1)
                @nbits+=1
                n = n / 2
            end
    	end

        def initTable()
            @tbl = []


            for i in 0..255
                @tbl[i] = -1
                i+=1
            end

            i = 0
            for i in 0..@base.length()
                if !@base.get(i).nil?
                    @tbl[@base.get(i)] = i
                end
                i+=1
            end

        end

        def decodeBytes(b)
            if @tbl.nil?
                initTable()
            end

            bitsize = b.length() * @nbits
            size = bitsize/8
            o = []
            buf = 0
            curbits = 0
            pin = 0
            pout = 0
             while (pout < size)
                while (curbits < 8)
                    curbits += @nbits
                    buf <<=  @nbits
                    i = @tbl[b.get(pin)]
                    pin+=1
                    buf |= i
                end
                curbits -= 8
                o[pout] = ((buf >> curbits) & 0xFF)
                pout += 1;
            end

            return Bytes.ofData(o)
        end

        def encodeBytes(b)
            bas = @base
            size = (b.length()*8)/@nbits
            o = []
            buf = 0
            curbits = 0
            mask = (1 << @nbits) -1
            pin = 0
            pout = 0
            while (pout < size)
                while (curbits < @nbits)
                    curbits += 8
                    buf <<= 8
                    buf |= b.get(pin)
                    pin +=1
                end
                curbits -= @nbits
                o[pout] = bas.get((buf >> curbits) & mask)
                pout+=1
            end
            if (curbits > 0)
                o[pout] = bas.get((buf << (@nbits - curbits)) & mask)
                pout +=1
            end
            return Bytes.ofData(o)
        end
    end
end