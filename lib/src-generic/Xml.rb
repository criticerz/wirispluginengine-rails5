require "rexml/document"
module Wiris
	class Xml
		include REXML
		include Comparable
	  @node
	  @nodeName
	  @nodeType
	  Element = :element
	  PCData = :text
	  CData = :text

	  	def node=(node)
			@node=node
		end
		def node
			@node
		end

		def nodeName=(nodeName)
			@nodeName=nodeName
		end
		def nodeName
			@nodeName
		end

		def nodeType=(nodeType)
			@nodeType=nodeType
		end
		def nodeType
			@nodeType
		end

		def initialize(node)
			@node =node
			@nodeType = node.node_type
			if node.class == REXML::CData
				@nodeType = :text
			end
			if (@nodeType == :text)
				@nodeName = :text
			elsif (@nodeType == :text)
				@nodeName = :text
			else
				@nodeName = node.name
			end

		end
		def self.parse(xml)
			return Xml.new REXML::Document.new xml
		end

		def iterator()
			return XmlIterator.new(@node.each)
		end

		def elements()
			childElements = Array.new
			node = nil
			if (self.firstChild() != nil)
				node = self.firstChild().node
			end

			while (!node.nil?)
				if (node.node_type == :element)
					childElements.push(node)
				end
			node = node.next_sibling
			end
			# return XmlIterator.new(childElements.each)
			return XmlIterator.new childElements.each
		end

	    def attributes()
	        atts = Array.new;
	        if @node.attributes.nil?
	             return Iterator.new
	        end

	        @node.attributes.each_attribute { |attr|
				atts.push(attr.expanded_name)
			}

	        return Iterator.new atts.each
	    end

	    def get(attributeName)
	        return @node.attributes[attributeName]
	    end

	    def remove(attributeName)
	    	if !@node.attributes[attributeName].nil?
	    		@node.attributes.delete attributeName
	    	end
	    end

	    def set(attributeName, attributeValue)
	        newAtrribute = REXML::Attribute.new(attributeName, attributeValue);
	        @node.attributes.add(newAtrribute)
	    end

	    def parent_()
	    	if @node.parent.nil?
	    		return nil
	    	end
	    	return Xml.new @node.parent
	    end

		def firstChild()
			if defined?(@node.each_child).nil? || @node.each_child.count == 0
				return nil
			end

			return Xml.new @node.each_child.next
		end

		def firstElement()
			@node.each_recursive {|e|
	 				if e.class == REXML::Element
	 					return Xml.new e
	 				end
			}
			return nil
		end

		def addChild(x)
			@node << x.node
		end

		def insertChild(x, pos)
			if pos < 0
			end
			# On ruby first index starts at 1.
			# Check if node has childs, if not insert node directly.
			if @node.elements[1].nil?
				xmlparsed.firstChild.addChild(x)
			else
				@node.insert_before(@node.elements[1], x.node)
			end
		end
		def removeChild(x)
			remove = @node == x.node.parent
			if remove
				x.node.remove
			end
		end

		def self.createDocument()
			return Xml.new REXML::Document.new
		end

		def createElement_(name)
			elementNode = REXML::Element.new name
			return Xml.new elementNode
		end

		def createPCData_(text)
			textNode = Text.new text
			return Xml.new textNode
		end

		def getNodeValue_()
			if (@node.node_type == :text || @node.node_type == :node)
				return @node.value
			else
				return @node.text
			end
		end

		def createCData_(text)
			elem = REXML::CData.new(text)
			return Xml.new elem
		end

		def toString()
			return @node.to_s
		end
	end


	class XmlIterator < Enumerator
		def initialize(enum)
			super(enum)
		end
		alias enumeratornext next
		def next
		    Xml.new self.enumeratornext
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