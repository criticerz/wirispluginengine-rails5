module Wiris
    class Serializer
    	def buf
    		@buf
    	end
    	def initialize()
    		@buf = StringBuf.new()
    	end

    	##
    	# a : array
        # b : hash
        # c : class
        # d : Float
        # e : reserved (float exp)
        # f : false
        # g : object end
        # h : array/list/hash end
        # i : Int
        # j : enum (by index)
        # k : NaN
        # l : list
        # m : -Inf
        # n : null
        # o : object
        # p : +Inf
        # q : inthash
        # r : reference
        # s : bytes (base64)
        # t : true
        # u : array nulls
        # v : date
        # w : enum
        # x : exceptiona
        # y : urlencoded string
        # z : zero
        # C : custom

        def serialize(o)
        	c = Type.getClass(o)
        	if (c == Type.resolveClass(Array).to_s)
        		buf.add("a")
        		v = o
        		ucount = 0
        		l = v.length()
        		for i in 0..l
        			if (v._(i) == nil)
        				ucount += 1
        			else
        				if (ucount > 0)
        					if (ucount == 1)
        						buf.add("n")
        					else
        						buf.add("u")
        						buf.add("" + ucount.to_s)
        					end
        					ucount = 0
        				end
        				serialize(v._(i))
        			end
        		end
        		buf.add("h")
        	elsif (o.is_a? Integer)
        		if (o == 0)
        			buf.add("z")
        		else
        			buf.add("i")
        			buf.add("" + o.to_s)
        		end
        	else
        		raise Exception, "Object class not implemented: "+  c
        	end
        end

        def toString() 
        	return buf.toString()
        end

        def self.run(o)
        	s = Serializer.new()
        	s.serialize(o)
        	return s.toString()
        end
    end
end