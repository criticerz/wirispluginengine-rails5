module Wiris
  class Type
    def self.resolveClass(name)
      name = name.to_s
      name = name.split(".").last
      return Object.const_get("Wiris::" + name)
      rescue Exception => exc
        return nil
    end

    def self.getClass(o)
      return o.class.name
    end

    def self.createInstance(cls, args)
      return cls.new()
    end
  end
end