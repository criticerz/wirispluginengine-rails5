module Wiris
	class EReg
		def regex=(regex)
			@regex=regex
		end
		def regex
			@regex
		end

		def match=(match)
			@match=match
		end
		def match
			@match
		end

		def initialize(pattern, opts=nil)
			flags = 0
			if not opts.nil?
				for i in 0..opts.length
					case opts[i]
					when "i"
						flags += Regexp::IGNORECASE
					when "s"
						flags +=  Regexp::MULTILINE
					when "m"
						flags +=  Regexp::MULTILINE
					end
				end
			end
			@regex = Regexp.new(pattern, flags)
		end

		def match(str)
			@match = @regex.match(str)
			if (@match.nil?)
				return false
			else
				return true
			end
		end

		def replace(str, by)
			@match = @regex.match(str)
			if @match.nil?
				return str
			else
				return str.gsub(@match.regexp, by)
			end
		end

		def matched(n)
			return @match[n]
		end
	end
end