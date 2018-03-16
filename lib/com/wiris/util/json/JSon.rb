module WirisPlugin
include  Wiris
require('com/wiris/util/json/StringParser.rb')
require('com/wiris/util/json/JSonIntegerFormat.rb')
require('com/wiris/common/WInteger.rb')
require('com/wiris/util/xml/WCharacterBase.rb')
require('com/wiris/util/json/StringParser.rb')
  class JSon < StringParser
  include Wiris

    def self.sb
      @@sb
    end
    def self.sb=(sb)
      @@sb = sb
    end
    attr_accessor :addNewLines
    attr_accessor :depth
    attr_accessor :lastDepth
    def initialize()
      super()
    end
    def self.encode(o)
      js = JSon.new()
      return js::encodeObject(o)
    end
    def encodeObject(o)
      sb = StringBuf.new()
      @depth = 0
      encodeImpl(sb,o)
      return sb::toString()
    end
    def encodeImpl(sb,o)
      if TypeTools::isHash(o)
        encodeHash(sb,(o))
      else 
        if TypeTools::isArray(o)
          encodeArray(sb,(o))
        else 
          if o.instance_of?String
            encodeString(sb,(o))
          else 
            if o.instance_of?Integer
              encodeInteger(sb,(o))
            else 
              if o.instance_of?Long
                encodeLong(sb,(o))
              else 
                if o.instance_of?JSonIntegerFormat
                  encodeIntegerFormat(sb,(o))
                else 
                  if o.instance_of?Boolean
                    encodeBoolean(sb,(o))
                  else 
                    if o.instance_of?Double
                      encodeFloat(sb,(o))
                    else 
                      raise Exception,"Impossible to convert to json object of type "+Type::getClass(o).to_s
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    def encodeHash(sb,h)
      newLines = @addNewLines&&(self.class.getDepth(h)>2)
      @depth+=1
      myDepth = @lastDepth
      sb::add("{")
      if newLines
        newLine(@depth,sb)
      end
      e = h::keys()
      first = true
      while e::hasNext()
        if first
          first = false
        else 
          sb::add(",")
          if newLines
            newLine(@depth,sb)
          end
        end
        key = e::next()
        encodeString(sb,key)
        sb::add(":")
        encodeImpl(sb,h::get(key))
      end
      if newLines
        newLine(myDepth,sb)
      end
      sb::add("}")
      @depth-=1
    end
    def encodeArray(sb,v)
      newLines = @addNewLines&&(self.class.getDepth(v)>2)
      @depth+=1
      myDepth = @lastDepth
      sb::add("[")
      if newLines
        newLine(@depth,sb)
      end
        for i in 0..v::length()-1
          o = v::_(i)
          if i>0
            sb::add(",")
            if newLines
              newLine(@depth,sb)
            end
          end
          encodeImpl(sb,o)
          i+=1
        end
      if newLines
        newLine(myDepth,sb)
      end
      sb::add("]")
      @depth-=1
    end
    def encodeString(sb,s)
      sb::add("\"")
        for i in 0..s::length()-1
          c = Std::charCodeAt(s,i)
          if c==34
            sb::add("\\\"")
          else 
            if c==13
              sb::add("\\r")
            else 
              if c==10
                sb::add("\\n")
              else 
                if c==9
                  sb::add("\\t")
                else 
                  if c==92
                    sb::add("\\\\")
                  else 
                    sb::add(s::charAt(i))
                  end
                end
              end
            end
          end
          i+=1
        end
      sb::add("\"")
    end
    def encodeInteger(sb,i)
      sb::add(""+i.to_s)
    end
    def encodeBoolean(sb,b)
      sb::add(b::booleanValue() ? "true" : "false")
    end
    def encodeFloat(sb,d)
      sb::add(TypeTools::floatToString(d))
    end
    def encodeLong(sb,i)
      sb::add(""+i.to_s)
    end
    def encodeIntegerFormat(sb,i)
      sb::add(i::toString())
    end
    def self.decode(str)
      json = JSon.new()
      return json::localDecodeString(str)
    end
    def localDecodeString(str)
      init(str)
      return localDecode()
    end
    def localDecode()
      skipBlanks()
      if c==123
        return decodeHash()
      else 
        if c==91
          return decodeArray()
        else 
          if c==34
            return decodeString()
          else 
            if c==39
              return decodeString()
            else 
              if (c==45)||((c>=48)&&(c<=58))
                return decodeNumber()
              else 
                if ((c==116)||(c==102))||(c==110)
                  return decodeBooleanOrNull()
                else 
                  raise Exception,"Unrecognized char "+c.to_s
                end
              end
            end
          end
        end
      end
    end
    def decodeBooleanOrNull()
      sb = StringBuf.new()
      while WCharacterBase::isLetter(c)
        sb::addChar(c)
        nextToken()
      end
      word = sb::toString()
      if (word=="true")
        return Boolean::TRUE
      else 
        if (word=="false")
          return Boolean::FALSE
        else 
          if (word=="null")
            return nil
          else 
            raise Exception,("Unrecognized keyword \""+word)+"\"."
          end
        end
      end
    end
    def decodeString()
      sb = StringBuf.new()
      d = c
      nextToken()
      while c!=d
        if c==92
          nextToken()
          if c==110
            sb::add("\n")
          else 
            if c==114
              sb::add("\r")
            else 
              if c==34
                sb::add("\"")
              else 
                if c==39
                  sb::add("\'")
                else 
                  if c==116
                    sb::add("\t")
                  else 
                    if c==92
                      sb::add("\\")
                    else 
                      if c==117
                        nextToken()
                        code = Utf8::uchr(c)
                        nextToken()
                        code+=Utf8::uchr(c)
                        nextToken()
                        code+=Utf8::uchr(c)
                        nextToken()
                        code+=Utf8::uchr(c)
                        dec = Std::parseInt("0x"+code)
                        sb::add(Utf8::uchr(dec))
                      else 
                        raise Exception,("Unknown scape sequence \'\\"+Utf8::uchr(c).to_s)+"\'"
                      end
                    end
                  end
                end
              end
            end
          end
        else 
          sb::add(Std::fromCharCode(c))
        end
        nextToken()
      end
      nextToken()
      return sb::toString()
    end
    def decodeNumber()
      sb = StringBuf.new()
      hex = false
      floating = false
      loop do
        sb::add(Std::fromCharCode(c))
        nextToken()
        if c==120
          hex = true
          sb::add(Std::fromCharCode(c))
          nextToken()
        end
        if ((c==46)||(c==69))||(c==101)
          floating = true
        end
      break if not (((c>=48)&&(c<=58))||(hex&&isHexDigit(c)))||(floating&&((((c==46)||(c==69))||(c==101))||(c==45)))
      end
      if floating
        return Std::parseFloat(sb::toString())
      else 
        return Std::parseInt(sb::toString())
      end
    end
    def decodeHash()
      h = Hash.new()
      nextToken()
      skipBlanks()
      if c==125
        nextToken()
        return h
      end
      while c!=125
        key = decodeString()
        skipBlanks()
        if c!=58
          raise Exception,"Expected \':\'."
        end
        nextToken()
        skipBlanks()
        o = localDecode()
        h::set(key,o)
        skipBlanks()
        if c==44
          nextToken()
          skipBlanks()
        else 
          if c!=125
            raise Exception,"Expected \',\' or \'}\'. "+getPositionRepresentation()
          end
        end
      end
      nextToken()
      return h
    end
    def decodeArray()
      v = Array.new()
      nextToken()
      skipBlanks()
      if c==93
        nextToken()
        return v
      end
      while c!=93
        o = localDecode()
        v::push(o)
        skipBlanks()
        if c==44
          nextToken()
          skipBlanks()
        else 
          if c!=93
            raise Exception,"Expected \',\' or \']\'."
          end
        end
      end
      nextToken()
      return v
    end
    def self.getDepth(o)
      if TypeTools::isHash(o)
        h = (o)
        m = 0
        if h::exists("_left_")||h::exists("_right_")
          if h::exists("_left_")
            m = WInteger::max(getDepth(h::get("_left_")),m)
          end
          if h::exists("_right_")
            m = WInteger::max(getDepth(h::get("_right_")),m)
          end
          return m
        end
        iter = h::keys()
        while iter::hasNext()
          key = iter::next()
          m = WInteger::max(getDepth(h::get(key)),m)
        end
        return m+2
      else 
        if TypeTools::isArray(o)
          a = (o)
          m = 0
            for i in 0..a::length()-1
              m = WInteger::max(getDepth(a::_(i)),m)
              i+=1
            end
          return m+1
        else 
          return 1
        end
      end
    end
    def setAddNewLines(addNewLines)
      @addNewLines = addNewLines
    end
    def newLine(depth,sb)
      sb::add("\r\n")
        for i in 0..depth-1
          sb::add("  ")
          i+=1
        end
      @lastDepth = depth
    end
    def self.getString(o)
      return (o)
    end
    def self.getFloat(n)
      if n.instance_of?Double
        return (n)
      else 
        if n.instance_of?Integer
          return (n)+0.0
        else 
          return 0.0
        end
      end
    end
    def self.getInt(n)
      if n.instance_of?Double
        return (Math::round((n)))
      else 
        if n.instance_of?Integer
          return (n)
        else 
          return 0
        end
      end
    end
    def self.getBoolean(b)
      return ((b))::booleanValue()
    end
    def self.getArray(a)
      return (a)
    end
    def self.getHash(a)
      return (a)
    end
    def self.compare(a,b,eps)
      if TypeTools::isHash(a)
        isBHash = TypeTools::isHash(b)
        if !isBHash
          return false
        end
        ha = (a)
        hb = (b)
        it = ha::keys()
        itb = hb::keys()
        while it::hasNext()
          if !itb::hasNext()
            return false
          end
          itb::next()
          key = it::next()
          if !hb::exists(key)||!compare(ha::get(key),hb::get(key),eps)
            return false
          end
        end
        if itb::hasNext()
          return false
        end
        return true
      else 
        if TypeTools::isArray(a)
          isBArray = TypeTools::isArray(b)
          if !isBArray
            return false
          end
          aa = (a)
          ab = (b)
          if aa::length()!=ab::length()
            return false
          end
            for i in 0..aa::length()-1
              if !compare(aa::_(i),ab::_(i),eps)
                return false
              end
              i+=1
            end
          return true
        else 
          if a.instance_of?String
            if !(b.instance_of?String)
              return false
            end
            return (a==b)
          else 
            if a.instance_of?Integer
              if !(b.instance_of?Integer)
                return false
              end
              return (a==b)
            else 
              if a.instance_of?Long
                isBLong = b.instance_of?Long
                if !isBLong
                  return false
                end
                return (a==b)
              else 
                if a.instance_of?JSonIntegerFormat
                  if !(b.instance_of?JSonIntegerFormat)
                    return false
                  end
                  ja = (a)
                  jb = (b)
                  return (ja::toString()==jb::toString())
                else 
                  if a.instance_of?Boolean
                    if !(b.instance_of?Boolean)
                      return false
                    end
                    return (a==b)
                  else 
                    if a.instance_of?Double
                      if !(b.instance_of?Double)
                        return false
                      end
                      da = getFloat(a)
                      db = getFloat(b)
                      return (da>=(db-eps))&&(da<=(db+eps))
                    end
                  end
                end
              end
            end
          end
        end
      end
      return true
    end
    def self.main(args)
      s1 = "{\"displays\":[{\"horizontal_axis_values_position\":\"below\",\"vertical_axis_label\":\"\",\"window_width\":450.,\"horizontal_axis_label\":\"\",\"styles\":[{\"color\":\"#9a0000\",\"ref\":\"line1\"},{\"color\":\"#105b5c\",\"ref\":\"conic1\"},{\"color\":\"#a3b017\",\"fixed\":false,\"ref\":\"point1\"},{\"color\":\"#a3b017\",\"fixed\":false,\"ref\":\"point2\"}],\"window_height\":450.,\"height\":21.,\"id\":\"plotter1\",\"grid_y\":true,\"width\":21.,\"grid_x\":true,\"axis_color\":\"#9696ff\",\"vertical_axis_values_position\":\"left\",\"grid_primary_color\":\"#ffc864\",\"background_color\":\"#fffff0\",\"axis_y\":true,\"axis_x\":true,\"center\":[0.,0.]}],\"elements\":[{\"type\":\"line_segment\",\"value-content\":\"<math  xmlns=\\\"http://www.w3.org/1998/Math/MathML\\\"><apply><eq></eq><ci>y</ci><ci>x</ci></apply></math>\",\"coordinates\":[[-31.5,-31.5],[31.5,31.5]],\"id\":\"line1\"},{\"type\":\"path\",\"value-content\":\"<math  xmlns=\\\"http://www.w3.org/1998/Math/MathML\\\"><apply><eq></eq><apply><plus></plus><apply><times></times><apply><minus></minus><apply><divide></divide><cn>1</cn><cn>4</cn></apply></apply><apply><power></power><ci>x</ci><cn>2</cn></apply></apply><ci>y</ci><cn>4</cn></apply><cn>0</cn></apply></math>\",\"coordinates\":[[9.795918464660645,19.99000358581543],[9.387755393981934,18.032485961914062],[8.979591369628906,16.158267974853516],[8.571428298950195,14.36734676361084],[8.163265228271484,12.659725189208984],[7.755102157592773,11.035402297973633],[7.346938610076904,9.494377136230469],[6.938775539398193,8.036651611328125],[6.530612468719482,6.662224292755127],[6.122448921203613,5.371095180511475],[5.714285850524902,4.163265228271484],[5.306122303009033,3.038733959197998],[4.897959232330322,1.997501015663147],[4.489795684814453,1.0395668745040894],[4.081632614135742,0.1649312824010849],[3.673469305038452,-0.626405656337738],[3.265306234359741,-1.3344439268112183],[2.857142925262451,-1.959183692932129],[2.448979616165161,-2.500624656677246],[2.040816307067871,-2.9587671756744385],[1.6326531171798706,-3.333611011505127],[1.2244898080825806,-3.6251561641693115],[0.8163265585899353,-3.833402633666992],[0.40816327929496765,-3.958350658416748],[0.,-4.],[-0.40816327929496765,-3.958350658416748],[-0.8163265585899353,-3.833402633666992],[-1.2244898080825806,-3.6251561641693115],[-1.6326531171798706,-3.333611011505127],[-2.040816307067871,-2.9587671756744385],[-2.448979616165161,-2.500624656677246],[-2.857142925262451,-1.959183692932129],[-3.265306234359741,-1.3344439268112183],[-3.673469305038452,-0.626405656337738],[-4.081632614135742,0.1649312824010849],[-4.489795684814453,1.0395668745040894],[-4.897959232330322,1.997501015663147],[-5.306122303009033,3.038733959197998],[-5.714285850524902,4.163265228271484],[-6.122448921203613,5.371095180511475],[-6.530612468719482,6.662224292755127],[-6.938775539398193,8.036651611328125],[-7.346938610076904,9.494377136230469],[-7.755102157592773,11.035402297973633],[-8.163265228271484,12.659725189208984],[-8.571428298950195,14.36734676361084],[-8.979591369628906,16.158267974853516],[-9.387755393981934,18.032485961914062],[-9.795918464660645,19.99000358581543],[-10.204081535339355,22.030820846557617]],\"id\":\"conic1\"},{\"type\":\"point\",\"value-content\":\"<math  xmlns=\\\"http://www.w3.org/1998/Math/MathML\\\"><vector><apply><plus></plus><apply><times></times><apply><minus></minus><cn>2</cn></apply><apply><root></root><cn>5</cn></apply></apply><cn>2</cn></apply><apply><plus></plus><apply><times></times><apply><minus></minus><cn>2</cn></apply><apply><root></root><cn>5</cn></apply></apply><cn>2</cn></apply></vector></math>\",\"coordinates\":[-2.4721360206604004,-2.4721360206604004],\"id\":\"point1\"},{\"type\":\"point\",\"value-content\":\"<math  xmlns=\\\"http://www.w3.org/1998/Math/MathML\\\"><vector><apply><plus></plus><apply><times></times><cn>2</cn><apply><root></root><cn>5</cn></apply></apply><cn>2</cn></apply><apply><plus></plus><apply><times></times><cn>2</cn><apply><root></root><cn>5</cn></apply></apply><cn>2</cn></apply></vector></math>\",\"coordinates\":[6.4721360206604,6.4721360206604],\"id\":\"point2\"}],\"constraints\":[]}"
      s2 = "{\"displays\":[{\"horizontal-axis-values-position\":\"below\",\"vertical-axis-label\":\"\",\"window-width\":450.,\"styles\":[{\"color\":\"#9a0000\",\"ref\":\"line1\"},{\"color\":\"#105b5c\",\"ref\":\"conic1\"},{\"color\":\"#a3b017\",\"fixed\":false,\"ref\":\"point1\"},{\"color\":\"#a3b017\",\"fixed\":false,\"ref\":\"point2\"}],\"background-color\":\"#fffff0\",\"height\":21.,\"id\":\"plotter1\",\"grid-y\":true,\"window-height\":450.,\"grid-x\":true,\"width\":21.,\"horizontal-axis-label\":\"\",\"vertical-axis-values-position\":\"left\",\"grid-primary-color\":\"#ffc864\",\"axis-color\":\"#9696ff\",\"axis-y\":true,\"axis-x\":true,\"center\":[0.,0.]}],\"elements\":[{\"type\":\"line_segment\",\"value-content\":\"<math  xmlns=\\\"http://www.w3.org/1998/Math/MathML\\\"><apply><eq></eq><ci>y</ci><ci>x</ci></apply></math>\",\"coordinates\":[[-31.5,-31.5],[31.5,31.5]],\"id\":\"line1\"},{\"type\":\"path\",\"value-content\":\"<math  xmlns=\\\"http://www.w3.org/1998/Math/MathML\\\"><apply><eq></eq><apply><plus></plus><apply><times></times><apply><minus></minus><apply><divide></divide><cn>1</cn><cn>4</cn></apply></apply><apply><power></power><ci>x</ci><cn>2</cn></apply></apply><ci>y</ci><cn>4</cn></apply><cn>0</cn></apply></math>\",\"coordinates\":[[9.795918464660645,19.99000358581543],[9.387755393981934,18.032485961914062],[8.979591369628906,16.158267974853516],[8.571428298950195,14.36734676361084],[8.163265228271484,12.659725189208984],[7.755102157592773,11.035402297973633],[7.346938610076904,9.494377136230469],[6.938775539398193,8.036651611328125],[6.530612468719482,6.662224292755127],[6.122448921203613,5.371095180511475],[5.714285850524902,4.163265228271484],[5.306122303009033,3.038733959197998],[4.897959232330322,1.997501015663147],[4.489795684814453,1.0395668745040894],[4.081632614135742,0.1649312824010849],[3.673469305038452,-0.626405656337738],[3.265306234359741,-1.3344439268112183],[2.857142925262451,-1.959183692932129],[2.448979616165161,-2.500624656677246],[2.040816307067871,-2.9587671756744385],[1.6326531171798706,-3.333611011505127],[1.2244898080825806,-3.6251561641693115],[0.8163265585899353,-3.833402633666992],[0.40816327929496765,-3.958350658416748],[0.,-4.],[-0.40816327929496765,-3.958350658416748],[-0.8163265585899353,-3.833402633666992],[-1.2244898080825806,-3.6251561641693115],[-1.6326531171798706,-3.333611011505127],[-2.040816307067871,-2.9587671756744385],[-2.448979616165161,-2.500624656677246],[-2.857142925262451,-1.959183692932129],[-3.265306234359741,-1.3344439268112183],[-3.673469305038452,-0.626405656337738],[-4.081632614135742,0.1649312824010849],[-4.489795684814453,1.0395668745040894],[-4.897959232330322,1.997501015663147],[-5.306122303009033,3.038733959197998],[-5.714285850524902,4.163265228271484],[-6.122448921203613,5.371095180511475],[-6.530612468719482,6.662224292755127],[-6.938775539398193,8.036651611328125],[-7.346938610076904,9.494377136230469],[-7.755102157592773,11.035402297973633],[-8.163265228271484,12.659725189208984],[-8.571428298950195,14.36734676361084],[-8.979591369628906,16.158267974853516],[-9.387755393981934,18.032485961914062],[-9.795918464660645,19.99000358581543],[-10.204081535339355,22.030820846557617]],\"id\":\"conic1\"},{\"type\":\"point\",\"value-content\":\"<math  xmlns=\\\"http://www.w3.org/1998/Math/MathML\\\"><vector><apply><plus></plus><apply><times></times><apply><minus></minus><cn>2</cn></apply><apply><root></root><cn>5</cn></apply></apply><cn>2</cn></apply><apply><plus></plus><apply><times></times><apply><minus></minus><cn>2</cn></apply><apply><root></root><cn>5</cn></apply></apply><cn>2</cn></apply></vector></math>\",\"coordinates\":[-2.4721360206604004,-2.4721360206604004],\"id\":\"point1\"},{\"type\":\"point\",\"value-content\":\"<math  xmlns=\\\"http://www.w3.org/1998/Math/MathML\\\"><vector><apply><plus></plus><apply><times></times><cn>2</cn><apply><root></root><cn>5</cn></apply></apply><cn>2</cn></apply><apply><plus></plus><apply><times></times><cn>2</cn><apply><root></root><cn>5</cn></apply></apply><cn>2</cn></apply></vector></math>\",\"coordinates\":[6.4721360206604,6.4721360206604],\"id\":\"point2\"}],\"constraints\":[]}"
      if JSon::compare(JSon::decode(s1),JSon::decode(s2),1.0E-8)
        Std::trace("Equal")
      else 
        Std::trace("Not equal")
      end
    end
  end
end
