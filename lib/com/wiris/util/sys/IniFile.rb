module WirisPlugin
include  Wiris
  class IniFile
  include Wiris

    attr_accessor :filename
    attr_accessor :props
    def initialize()
      super()
      @props = Hash.new()
    end
    def self.newIniFileFromFilename(path)
      ini = IniFile.new()
      ini::filename = path
      ini::loadINI()
      return ini
    end
    def self.newIniFileFromString(inifile)
      ini = IniFile.new()
      ini::filename = ""
      ini::loadProperties(inifile)
      return ini
    end
    def getProperties()
      return @props
    end
    def loadINI()
      s = Storage::newStorage(@filename)
      if !s::exists()
        s = Storage::newResourceStorage(@filename)
      end
      begin
      file = s::read()
      if file!=nil
        loadProperties(file)
      end
      end
    end
    def loadPropertiesLine(line,count)
      line = StringTools::trim(line)
      if line::length()==0
        return 
      end
      if StringTools::startsWith(line,";")||StringTools::startsWith(line,"#")
        return 
      end
      equals = line::indexOf("=")
      if equals==-1
        raise Exception,((("Malformed INI file "+@filename)+" in line ")+count.to_s)+" no equal sign found."
      end
      key = Std::substr(line,0,equals)
      key = StringTools::trim(key)
      value = Std::substr(line,equals+1)
      value = StringTools::trim(value)
      if StringTools::startsWith(value,"\"")&&StringTools::endsWith(value,"\"")
        value = Std::substr(value,1,value::length()-2)
      end
      backslash = 0
      while (backslash = value::indexOf("\\",backslash))!=-1
        if value::length()<=(backslash+1)
            next
        end
        letter = Std::substr(value,backslash+1,1)
        if (letter=="n")
          letter = "\n"
        else 
          if (letter=="r")
            letter = "\r"
          else 
            if (letter=="t")
              letter = "\t"
            end
          end
        end
        value = (Std::substr(value,0,backslash).to_s+letter)+Std::substr(value,backslash+2).to_s
        backslash+=1
      end
      props::set(key,value)
    end
    def loadProperties(file)
      _end = 0
      count = 1
      while (start = file::indexOf("\n",_end))!=-1
        line = Std::substr(file,_end,start-_end)
        _end = start+1
        loadPropertiesLine(line,count)
        count+=1
      end
      if _end<file::length()
        line = Std::substr(file,_end)
        loadPropertiesLine(line,count)
      end
    end
    def self.propertiesToString(h)
      sb = StringBuf.new()
      iter = h::keys()
      keys = Array.new()
      while iter::hasNext()
        keys::push(iter::next())
      end
      n = keys::length()
        for i in 0..n-1
            for j in i+1..n-1
              s1 = keys::_(i)
              s2 = keys::_(j)
              if compareStrings(s1,s2)>0
                keys::_(i,s2)
                keys::_(j,s1)
              end
              j+=1
            end
          i+=1
        end
        for i in 0..n-1
          key = keys::_(i)
          sb::add(key)
          sb::add("=")
          value = h::get(key)
          value = StringTools::replace(value,"\\","\\\\")
          value = StringTools::replace(value,"\n","\\n")
          value = StringTools::replace(value,"\r","\\r")
          value = StringTools::replace(value,"\t","\\t")
          sb::add(value)
          sb::add("\n")
          i+=1
        end
      return sb::toString()
    end
    def self.compareStrings(a,b)
      an = a::length()
      bn = b::length()
      n = (an>bn) ? bn : an
        for i in 0..n-1
          c = Std::charCodeAt(a,i)-Std::charCodeAt(b,i)
          if c!=0
            return c
          end
          i+=1
        end
      return a::length()-b::length()
    end
  end
end
