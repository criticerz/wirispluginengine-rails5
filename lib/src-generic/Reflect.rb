module Wiris
    class Reflect
        def self.field(obj, field)
        begin
            cls = Module::const_get(obj.name)
            return cls.class_variable_get(("@@" + field).to_sym)
        end
        rescue NameError
            return nil
        end

        def self.setField(obj, field, value)
    		cls = Module::const_get(obj.name)
    		cls.class_variable_set(("@@" + field), value)
    	end
    end
end