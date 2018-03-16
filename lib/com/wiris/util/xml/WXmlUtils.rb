module WirisPlugin
include  Wiris
require('com/wiris/util/xml/WEntities.rb')
require('com/wiris/common/WInteger.rb')
  class WXmlUtils
  include Wiris

    def initialize()
      super()
    end
    def self.getElementContent(element)
      sb = StringBuf.new()
      if (element::nodeType==Xml::Document)||(element::nodeType==Xml::Element)
        i = element::iterator()
        while i::hasNext()
          sb::add(i::next()::toString())
        end
      end
      return sb::toString()
    end
    def self.getElementsByAttributeValue(nodeList,attributeName,attributeValue)
      nodes = Array.new()
      while nodeList::hasNext()
        node = nodeList::next()
        if (node::nodeType==Xml::Element)&&(attributeValue==WXmlUtils::getAttribute(node,attributeName))
          nodes::push(node)
        end
      end
      return nodes
    end
    def self.getElementsByTagName(nodeList,tagName)
      nodes = Array.new()
      while nodeList::hasNext()
        node = nodeList::next()
        if (node::nodeType==Xml::Element)&&(node::nodeName==tagName)
          nodes::push(node)
        end
      end
      return nodes
    end
    def self.getElements(node)
      nodes = Array.new()
      nodeList = node::iterator()
      while nodeList::hasNext()
        item = nodeList::next()
        if item::nodeType==Xml::Element
          nodes::push(item)
        end
      end
      return nodes
    end
    def self.getDocumentElement(doc)
      nodeList = doc::iterator()
      while nodeList::hasNext()
        node = nodeList::next()
        if node::nodeType==Xml::Element
          return node
        end
      end
      return nil
    end
    def self.getAttribute(node,attributeName)
      value = node::get(attributeName)
      if value==nil
        return nil
      end
      if PlatformSettings::PARSE_XML_ENTITIES
        return WXmlUtils::htmlUnescape(value)
      end
      return value
    end
    def self.setAttribute(node,name,value)
      if (value!=nil)&&PlatformSettings::PARSE_XML_ENTITIES
        value = WXmlUtils::htmlEscape(value)
      end
      node::set(name,value)
    end
    def self.getNodeValue(node)
      value = node::getNodeValue_()
      if value==nil
        return nil
      end
      if PlatformSettings::PARSE_XML_ENTITIES&&(node::nodeType==Xml::PCData)
        return WXmlUtils::htmlUnescape(value)
      end
      return value
    end
    def self.createPCData(node,text)
      if PlatformSettings::PARSE_XML_ENTITIES
        text = WXmlUtils::htmlEscape(text)
      end
      return node::createPCData_(text)
    end
    def self.htmlEscape(input)
      output = StringTools::replace(input,"&","&amp;")
      output = StringTools::replace(output,"<","&lt;")
      output = StringTools::replace(output,">","&gt;")
      output = StringTools::replace(output,"\"","&quot;")
      output = StringTools::replace(output,"&apos;","\'")
      return output
    end
    def self.htmlUnescape(input)
      output = ""
      start = 0
      position = input::indexOf('&',start)
      while position!=-1
        output+=Std::substr(input,start,position-start)
        if input::charAt(position+1)=='#'
          startPosition = position+2
          endPosition = input::indexOf(';',startPosition)
          if endPosition!=-1
            number = Std::substr(input,startPosition,endPosition-startPosition)
            if StringTools::startsWith(number,"x")
              number = "0"+number
            end
            charCode = Std::parseInt(number)
            output+=Utf8::uchr(charCode)
            start = endPosition+1
          else 
            output+='&'
            start = position+1
          end
        else 
          output+='&'
          start = position+1
        end
        position = input::indexOf('&',start)
      end
      output+=Std::substr(input,start,input::length()-start)
      output = StringTools::replace(output,"&lt;","<")
      output = StringTools::replace(output,"&gt;",">")
      output = StringTools::replace(output,"&quot;","\"")
      output = StringTools::replace(output,"&apos;","\'")
      output = StringTools::replace(output,"&amp;","&")
      return output
    end
  @@entities = nil
    def self.entities
      @@entities
    end
    def self.entities=(entities)
      @@entities = entities
    end
    def self.parseXML(xml)
      xml = filterMathMLEntities(xml)
      x = Xml::parse(xml)
      return x
    end
    def self.serializeXML(xml)
      s = xml::toString()
      s = filterMathMLEntities(s)
      return s
    end
    def self.resolveEntities(text)
      initEntities()
      sb = StringBuf.new()
      i = 0
      n = text::length()
      while i<n
        c = getUtf8Char(text,i)
        if ((c==60)&&((i+12)<n))&&(Std::charCodeAt(text,i+1)==33)
          if (Std::substr(text,i,9)=="<![CDATA[")
            e = text::indexOf("]]>",i)
            if e!=-1
              sb::add(Std::substr(text,i,(e-i)+3))
              i = e+3
                next
            end
          end
        end
        if c>127
          special = Utf8::uchr(c)
          sb::add(special)
          i+=special::length()-1
        else 
          if c==38
            i+=1
            c = Std::charCodeAt(text,i)
            if isNameStart(c)
              name = StringBuf.new()
              name::addChar(c)
              i+=1
              c = Std::charCodeAt(text,i)
              while isNameChar(c)
                name::addChar(c)
                i+=1
                c = Std::charCodeAt(text,i)
              end
              ent = name::toString()
              if ((c==59)&&@@entities::exists(ent))&&!(isXmlEntity(ent))
                val = @@entities::get(ent)
                sb::add(Utf8::uchr(Std::parseInt(val)))
              else 
                sb::add("&")
                sb::add(name)
                sb::addChar(c)
              end
            else 
              if c==35
                i+=1
                c = Std::charCodeAt(text,i)
                if c==120
                  hex = StringBuf.new()
                  i+=1
                  c = Std::charCodeAt(text,i)
                  while isHexDigit(c)
                    hex::addChar(c)
                    i+=1
                    c = Std::charCodeAt(text,i)
                  end
                  hent = hex::toString()
                  if (c==59)&&!isXmlEntity("#x"+hent)
                    dec = Std::parseInt("0x"+hent)
                    sb::add(Utf8::uchr(dec))
                  else 
                    sb::add("&#x")
                    sb::add(hent)
                    sb::addChar(c)
                  end
                else 
                  if ((48<=c)&&(c<=57))
                    dec = StringBuf.new()
                    while ((48<=c)&&(c<=57))
                      dec::addChar(c)
                      i+=1
                      c = Std::charCodeAt(text,i)
                    end
                    if (c==59)&&!isXmlEntity("#"+dec.to_s)
                      sb::add(Utf8::uchr(Std::parseInt(dec::toString())))
                    else 
                      sb::add("&#"+dec::toString().to_s)
                      sb::addChar(c)
                    end
                  end
                end
              end
            end
          else 
            sb::addChar(c)
          end
        end
        i+=1
      end
      return sb::toString()
    end
    def self.filterMathMLEntities(text)
      text = resolveEntities(text)
      text = nonAsciiToEntities(text)
      return text
    end
    def self.getUtf8Char(text,i)
      c = Std::charCodeAt(text,i)
      d = c
      if PlatformSettings::UTF8_CONVERSION
        if d>127
          j = 0
          c = 128
          loop do
            c = c>>1
            j+=1
          break if not (d&c)!=0
          end
          d = (c-1)&d
          while j-=1>0
            i+=1
            c = Std::charCodeAt(text,i)
            d = (d<<6)+(c&63)
          end
        end
      else 
        if (d>=55296)&&(d<=56319)
          c = Std::charCodeAt(text,i+1)
          d = (((d-55296)<<10)+((c-56320)))+65536
        end
      end
      return d
    end
    def self.nonAsciiToEntities(s)
      sb = StringBuf.new()
      i = 0
      n = s::length()
      while i<n
        c = getUtf8Char(s,i)
        if c>127
          hex = WInteger::toHex(c,5)
          j = 0
          while j<hex::length()
            if !((Std::substr(hex,j,1)=="0"))
              hex = Std::substr(hex,j)
              break
            end
            j+=1
          end
          sb::add(("&#x"+hex)+";")
          i+=(Utf8::uchr(c))::length()
        else 
          sb::addChar(c)
          i+=1
        end
      end
      return sb::toString()
    end
    def self.isNameStart(c)
      if (65<=c)&&(c<=90)
        return true
      end
      if (97<=c)&&(c<=122)
        return true
      end
      if (c==95)||(c==58)
        return true
      end
      return false
    end
    def self.isNameChar(c)
      if isNameStart(c)
        return true
      end
      if (48<=c)&&(c<=57)
        return true
      end
      if (c==46)||(c==45)
        return true
      end
      return false
    end
    def self.isHexDigit(c)
      if (c>=48)&&(c<=57)
        return true
      end
      if (c>=65)&&(c<=70)
        return true
      end
      if (c>=97)&&(c<=102)
        return true
      end
      return false
    end
    def self.resolveMathMLEntity(name)
      initEntities()
      if @@entities::exists(name)
        code = @@entities::get(name)
        return Std::parseInt(code)
      end
      return -1
    end
    def self.initEntities()
      if @@entities==nil
        e = WEntities::MATHML_ENTITIES
        @@entities = Hash.new()
        start = 0
        while (mid = e::indexOf("@",start))!=-1
          name = Std::substr(e,start,mid-start)
          mid+=1
          start = e::indexOf("@",mid)
          if start==-1
            break
          end
          value = Std::substr(e,mid,start-mid)
          num = Std::parseInt("0x"+value)
          @@entities::set(name,""+num.to_s)
          start+=1
        end
      end
    end
    def self.getText(xml)
      if xml::nodeType==Xml::PCData
        return xml::getNodeValue_()
      end
      r = ""
      iter = xml::iterator()
      while iter::hasNext()
        r+=getText(iter::next())
      end
      return r
    end
    def self.copyXml(elem)
      return importXml(elem,elem)
    end
    def self.importXml(elem,model)
      n = nil
      if elem::nodeType==Xml::Element
        n = model::createElement_(elem::nodeName)
        keys = elem::attributes()
        while keys::hasNext()
          key = keys::next()
          n::set(key,elem::get(key))
        end
        children = elem::iterator()
        while children::hasNext()
          n::addChild(importXml(children::next(),model))
        end
      else 
        if elem::nodeType==Xml::Document
          n = importXml(elem::firstElement(),model)
        else 
          if elem::nodeType==Xml::CData
            n = model::createCData_(elem::getNodeValue_())
          else 
            if elem::nodeType==Xml::PCData
              n = model::createPCData_(elem::getNodeValue_())
            else 
              raise Exception,"Unsupported node type: "+elem::nodeType.to_s
            end
          end
        end
      end
      return n
    end
    def self.copyXmlNamespace(elem,customNamespace)
      return importXmlNamespace(elem,elem,customNamespace)
    end
    def self.importXmlNamespace(elem,model,customNamespace)
      n = nil
      if elem::nodeType==Xml::Element
        n = model::createElement_((customNamespace+":")+elem::nodeName.to_s)
        keys = elem::attributes()
        while keys::hasNext()
          key = keys::next()
          keyNamespaced = key
          if key::indexOf(":")==-1
            keyNamespaced = (customNamespace+":")+key
          end
          n::set(keyNamespaced,elem::get(key))
        end
        children = elem::iterator()
        while children::hasNext()
          n::addChild(importXmlNamespace(children::next(),model,customNamespace))
        end
      else 
        if elem::nodeType==Xml::Document
          n = importXmlNamespace(elem::firstElement(),model,customNamespace)
        else 
          if elem::nodeType==Xml::CData
            n = model::createCData_(elem::getNodeValue_())
          else 
            if elem::nodeType==Xml::PCData
              n = model::createPCData_(elem::getNodeValue_())
            else 
              raise Exception,"Unsupported node type: "+elem::nodeType.to_s
            end
          end
        end
      end
      return n
    end
    def self.indentXml(xml,space)
      depth = 0
      opentag = EReg.new("^<([\\w-_]+)[^>]*>$","")
      autotag = EReg.new("^<([\\w-_]+)[^>]*/>$","")
      closetag = EReg.new("^</([\\w-_]+)>$","")
      cdata = EReg.new("^<!\\[CDATA\\[[^\\]]*\\]\\]>$","")
      res = StringBuf.new()
      _end = 0
      while (_end<xml::length())&&((start = xml::indexOf("<",_end))!=-1)
        text = start>_end
        if text
          res::add(Std::substr(xml,_end,start-_end))
        end
        _end = xml::indexOf(">",start)+1
        aux = Std::substr(xml,start,_end-start)
        if autotag::match(aux)
          res::add("\n")
            for i in 0..depth-1
              res::add(space)
              i+=1
            end
          res::add(aux)
        else 
          if opentag::match(aux)
            res::add("\n")
              for i in 0..depth-1
                res::add(space)
                i+=1
              end
            res::add(aux)
            depth+=1
          else 
            if closetag::match(aux)
              depth-=1
              if !text
                res::add("\n")
                  for i in 0..depth-1
                    res::add(space)
                    i+=1
                  end
              end
              res::add(aux)
            else 
              if cdata::match(aux)
                res::add(aux)
              else 
                Std::trace((("WARNING! malformed XML at character "+_end.to_s)+":")+xml)
                res::add(aux)
              end
            end
          end
        end
      end
      return StringTools::trim(res::toString())
    end
    def self.isXmlEntity(ent)
      if Std::charCodeAt(ent,0)==35
        if Std::charCodeAt(ent,1)==120
          c = Std::parseInt("0x"+Std::substr(ent,2).to_s)
        else 
          c = Std::parseInt(Std::substr(ent,1))
        end
        return (((((c==34)||(c==38))||(c==39))||(c==60))||(c==62))
      else 
        return (((((ent=="amp")||(ent=="lt"))||(ent=="gt"))||(ent=="quot"))||(ent=="apos"))
      end
    end
  end
end
