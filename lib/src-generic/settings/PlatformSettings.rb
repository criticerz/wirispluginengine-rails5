module Wiris
    class PlatformSettings
        PARSE_XML_ENTITIES = false
        IS_CSHARP = false
        IS_JAVA = true
        IS_JAVASCRIPT = false
        IS_FLASH = false
        IS_RUBY = true
        UTF8_CONVERSION = false

        def isWinXP()
        	return false
        end

        def evenTokensBoxWidth()
        	return false
        end
    end
end