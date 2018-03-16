module WirisPlugin
include  Wiris
  class TextFilterTags
  include Wiris

    attr_accessor :in_mathopen
    attr_accessor :in_mathclose
    attr_accessor :in_double_quote
    attr_accessor :out_double_quote
    attr_accessor :in_open
    attr_accessor :out_open
    attr_accessor :in_close
    attr_accessor :out_close
    attr_accessor :in_entity
    attr_accessor :out_entity
    attr_accessor :in_quote
    attr_accessor :out_quote
    attr_accessor :in_appletopen
    attr_accessor :in_appletclose
    def initialize()
      super()
    end
    def self.newSafeXml()
      tags = TextFilterTags.new()
      tags::in_open = Std::fromCharCode(171)
      tags::in_close = Std::fromCharCode(187)
      tags::in_entity = Std::fromCharCode(167)
      tags::in_quote = "`"
      tags::in_double_quote = Std::fromCharCode(168)
      tags::init(tags)
      return tags
    end
    def self.newXml()
      tags = TextFilterTags.new()
      tags::in_open = "<"
      tags::in_close = ">"
      tags::in_entity = "&"
      tags::in_quote = "\'"
      tags::in_double_quote = "\""
      tags::init(tags)
      return tags
    end
    def init(tags)
      tags::in_appletopen = @in_open+"APPLET"
      tags::in_appletclose = (@in_open+"/APPLET")+@in_close
      tags::in_mathopen = @in_open+"math"
      tags::in_mathclose = (@in_open+"/math")+@in_close
      tags::out_open = "<"
      tags::out_close = ">"
      tags::out_entity = "&"
      tags::out_quote = "\'"
      tags::out_double_quote = "\""
    end
  end
end
