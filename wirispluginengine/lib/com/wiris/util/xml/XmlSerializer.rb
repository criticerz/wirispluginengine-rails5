module WirisPlugin
include  Wiris
require('com/wiris/util/xml/WXmlUtils.rb')
  class XmlSerializer
  include Wiris

  MODE_READ = 0
  MODE_WRITE = 1
  MODE_REGISTER = 2
  MODE_CACHE = 3
    attr_accessor :mode
    attr_accessor :element
    attr_accessor :children
    attr_accessor :child
    attr_accessor :elementStack
    attr_accessor :childrenStack
    attr_accessor :childStack
    attr_accessor :tags
    attr_accessor :rawxmls
    attr_accessor :currentTag
    attr_accessor :cache
    attr_accessor :cacheTagStackCount
    attr_accessor :ignore
    attr_accessor :ignoreTagStackCount
    def initialize()
      super()
      @tags = Hash.new()
      @elementStack = Array.new()
      @childrenStack = Array.new()
      @childStack = Array.new()
      @cacheTagStackCount = 0
      @ignoreTagStackCount = 0
    end
    def getMode()
      return @mode
    end
    def read(xml)
      document = Xml::parse(xml)
      setCurrentElement(document)
      @mode = XmlSerializer::MODE_READ
      return readNode()
    end
    def write(s)
      @mode = XmlSerializer::MODE_WRITE
      @element = Xml::createDocument()
      @rawxmls = Array.new()
      s::onSerialize(self)
      res = element::toString()
        for i in 0..rawxmls::length()-1
          start = res::indexOf(("<rawXml id=\""+i.to_s)+"\"")
          if start!=-1
            _end = res::indexOf(">",start)
            res = (Std::substr(res,0,start).to_s+rawxmls::_(i).to_s)+Std::substr(res,_end+1).to_s
          end
          i+=1
        end
      return res
    end
    def beginTagIf(tag,current,desired)
      if @mode==MODE_READ
        if beginTag(tag)
          return desired
        end
      else 
        if current==desired
          beginTag(tag)
        end
      end
      return current
    end
    def beginTagIfBool(tag,current,desired)
      if @mode==MODE_READ
        if beginTag(tag)
          return desired
        end
      else 
        if current==desired
          beginTag(tag)
        end
      end
      return current
    end
    def beginTag(tag)
      if @mode==MODE_READ
        if ((currentChild()!=nil)&&(currentChild()::nodeType==Xml::Element))&&(tag==currentChild()::nodeName)
          pushState()
          setCurrentElement(currentChild())
        else 
          return false
        end
      else 
        if @mode==MODE_WRITE
          if isIgnoreTag(tag)||(@ignoreTagStackCount>0)
            @ignoreTagStackCount+=1
          else 
            child = @element::createElement_(tag)
            @element::addChild(child)
            @element = child
          end
        else 
          if (@mode==MODE_REGISTER)&&(@currentTag==nil)
            @currentTag = tag
          else 
            if @mode==MODE_CACHE
              @cacheTagStackCount+=1
            end
          end
        end
      end
      return true
    end
    def endTag()
      if @mode==MODE_READ
        @element = @element::parent_()
        popState()
        nextChild()
      else 
        if @mode==MODE_WRITE
          if @ignoreTagStackCount>0
            @ignoreTagStackCount-=1
          else 
            @element = @element::parent_()
          end
        else 
          if @mode==MODE_CACHE
            if @cacheTagStackCount>0
              @cacheTagStackCount-=1
            else 
              @mode = MODE_WRITE
              @element = @element::parent_()
            end
          end
        end
      end
    end
    def attributeString(name,value,def_)
      if @mode==XmlSerializer::MODE_READ
        value = WXmlUtils::getAttribute(@element,name)
        if value==nil
          value = def_
        end
      else 
        if @mode==XmlSerializer::MODE_WRITE
          if ((value!=nil)&&!((value==def_)))&&(@ignoreTagStackCount==0)
            WXmlUtils::setAttribute(@element,name,value)
          end
        end
      end
      return value
    end
    def cacheAttribute(name,value,def_)
      if @mode==XmlSerializer::MODE_WRITE
        if @cache
          value = attributeString(name,value,def_)
          @mode = XmlSerializer::MODE_CACHE
          @cacheTagStackCount = 0
        end
      else 
        value = attributeString(name,value,def_)
      end
      return value
    end
    def attributeBoolean(name,value,def_)
      return XmlSerializer::parseBoolean(attributeString(name,XmlSerializer::booleanToString(value),XmlSerializer::booleanToString(def_)))
    end
    def attributeInt(name,value,def_)
      return Std::parseInt(attributeString(name,""+value.to_s,""+def_.to_s))
    end
    def attributeIntArray(name,value,def_)
      return stringToArray(attributeString(name,arrayToString(value),arrayToString(def_)))
    end
    def arrayToString(a)
      if a==nil
        return nil
      end
      sb = StringBuf.new()
        for i in 0..a::length-1
          if i!=0
            sb::add(",")
          end
          sb::add(a[i].to_s+"")
          i+=1
        end
      return sb::toString()
    end
    def stringToArray(s)
      if s==nil
        return nil
      end
      ss = s::split(",")
      a = []
        for i in 0..ss::length-1
          a[i] = Std::parseInt(ss[i])
          i+=1
        end
      return a
    end
    def attributeFloat(name,value,def_)
      return Std::parseFloat(attributeString(name,""+value.to_s,""+def_.to_s))
    end
    def textContent(content)
      if @mode==MODE_READ
        content = XmlSerializer::getXmlTextContent(@element)
      else 
        if ((@mode==MODE_WRITE)&&(content!=nil))&&(@ignoreTagStackCount==0)
          if (content::length()>100)||(StringTools::startsWith(content,"<")&&StringTools::endsWith(content,">"))
            textNode = @element::createCData_(content)
          else 
            textNode = WXmlUtils::createPCData(@element,content)
          end
          element::addChild(textNode)
        end
      end
      return content
    end
    def base64Content(data)
      b64 = BaseCode.new(Bytes::ofString("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"))
      if @mode==MODE_READ
        content = textContent(nil)
        data = b64::decodeBytes(Bytes::ofString(content))
      else 
        if @mode==MODE_WRITE
          textContent(b64::encodeBytes(data)::toString())
        end
      end
      return data
    end
    def rawXml(xml)
      if @mode==MODE_READ
        raise Exception,"Should not use rawXml() function on read operation!"
      else 
        if @mode==MODE_WRITE
          raw = @element::createElement_("rawXml")
          raw::set("id",""+rawxmls::length().to_s)
          rawxmls::push(xml)
          element::addChild(raw)
        else 
          if @mode==MODE_REGISTER
            @currentTag = getMainTag(xml)
          end
        end
      end
      return xml
    end
    def booleanContent(content)
      return XmlSerializer::parseBoolean(textContent(XmlSerializer::booleanToString(content)))
    end
    def floatContent(d)
      return Std::parseFloat(textContent(d.to_s+""))
    end
    def self.getXmlTextContent(element)
      if (element::nodeType==Xml::CData)||(element::nodeType==Xml::PCData)
        return WXmlUtils::getNodeValue(element)
      else 
        if (element::nodeType==Xml::Document)||(element::nodeType==Xml::Element)
          sb = StringBuf.new()
          children = element::iterator()
          while children::hasNext()
            sb::add(getXmlTextContent(children::next()))
          end
          return sb::toString()
        else 
          return ""
        end
      end
    end
    def serializeChild(s)
      if @mode==XmlSerializer::MODE_READ
        child = currentChild()
        if child!=nil
          s = (readNode())
        else 
          s = nil
        end
      else 
        if (@mode==XmlSerializer::MODE_WRITE)&&(s!=nil)
          (s)::onSerialize(self)
        end
      end
      return s
    end
    def serializeArray(array,tagName)
      if @mode==XmlSerializer::MODE_READ
        array = Array.new()
        child = currentChild()
        while (child!=nil)&&((tagName==nil)||(tagName==child::nodeName))
          elem = (readNode())
          array::push(elem)
          child = currentChild()
        end
      else 
        if ((@mode==XmlSerializer::MODE_WRITE)&&(array!=nil))&&(array::length()>0)
          items = array::iterator()
          while items::hasNext()
            (items::next())::onSerialize(self)
          end
        end
      end
      return array
    end
    def serializeChildName(s,tagName)
      if @mode==MODE_READ
        child = currentChild()
        if (child!=nil)&&(child::nodeName==tagName)
          s = serializeChild(s)
        end
      else 
        if @mode==MODE_WRITE
          s = serializeChild(s)
        end
      end
      return s
    end
    def serializeArrayName(array,tagName)
      if @mode==MODE_READ
        if beginTag(tagName)
          array = serializeArray(array,nil)
          endTag()
        end
      else 
        if ((@mode==MODE_WRITE)&&(array!=nil))&&(array::length()>0)
          element = @element
          @element = element::createElement_(tagName)
          element::addChild(@element)
          array = serializeArray(array,nil)
          @element = element
        else 
          if @mode==MODE_REGISTER
            beginTag(tagName)
          end
        end
      end
      return array
    end
    def register(elem)
      tags::set(getTagName(elem),elem)
    end
    def getTagName(elem)
      mode = @mode
      @mode = XmlSerializer::MODE_REGISTER
      @currentTag = nil
      elem::onSerialize(self)
      @mode = mode
      return @currentTag
    end
    def readNode()
      if !tags::exists(currentChild()::nodeName)
        raise Exception,("Tag "+currentChild()::nodeName.to_s)+" not registered."
      end
      model = tags::get(currentChild()::nodeName)
      return readNodeModel(model)
    end
    def readNodeModel(model)
      node = model::newInstance()
      node::onSerialize(self)
      return node
    end
    def setCurrentElement(element)
      @element = element
      @children = element::elements()
      @child = nil
    end
    def nextChild()
      if @children::hasNext()
        @child = @children::next()
      else 
        @child = nil
      end
      return @child
    end
    def currentChild()
      if (@child==nil)&&@children::hasNext()
        @child = @children::next()
      end
      return @child
    end
    def pushState()
      elementStack::push(@element)
      childrenStack::push(@children)
      childStack::push(@child)
    end
    def popState()
      @element = elementStack::pop()
      @children = childrenStack::pop()
      @child = childStack::pop()
    end
    def self.parseBoolean(s)
      return (s::toLowerCase()=="true")||(s=="1")
    end
    def self.booleanToString(b)
      return b ? "true" : "false"
    end
    def childString(name,value,def_)
      if !((@mode==MODE_WRITE)&&(((value==nil)&&(def_==nil))||((value!=nil)&&(value==def_))))
        if beginTag(name)
          value = textContent(value)
          endTag()
        end
      end
      return value
    end
    def childInt(name,value,def_)
      return Std::parseInt(childString(name,""+value.to_s,""+def_.to_s))
    end
    def setCached(cache)
      @cache = cache
    end
    def beginCache()
      if @cache&&(@mode==XmlSerializer::MODE_WRITE)
        @mode = XmlSerializer::MODE_CACHE
      end
    end
    def endCache()
      if @mode==XmlSerializer::MODE_CACHE
        @mode = XmlSerializer::MODE_WRITE
      end
    end
    def getMainTag(xml)
      i = 0
      loop do
        i = xml::indexOf("<",i)
        i+=1
        c = Std::charCodeAt(xml,i)
      break if not (c!=33)&&(c!=63)
      end
      _end = [">", " ", "/"]
      min = 0
        for j in 0.._end::length-1
          n = xml::indexOf(_end[j])
          if (n!=-1)&&(n<min)
            n = min
          end
          j+=1
        end
      return Std::substr(xml,i,min)
    end
    def serializeXml(tag,elem)
      if @mode==MODE_READ
        if (tag==nil)||((currentChild()!=nil)&&(currentChild()::nodeName==tag))
          elem = currentChild()
          nextChild()
        end
      else 
        if @mode==MODE_WRITE
          if (elem!=nil)&&(@ignoreTagStackCount==0)
            imported = WXmlUtils::importXml(elem,@element)
            element::addChild(imported)
          end
        else 
          if @mode==MODE_REGISTER
            beginTag(tag)
          end
        end
      end
      return elem
    end
    def setIgnoreTags(ignore)
      @ignore = ignore
    end
    def isIgnoreTag(s)
      if @ignore!=nil
        i = ignore::iterator()
        while i::hasNext()
          if (i::next()==s)
            return true
          end
        end
      end
      return false
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
