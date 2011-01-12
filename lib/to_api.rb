if Object.const_defined? :ActiveRecord
  class ActiveRecord::Base
    def to_api(*includes) #assumes all attribute types are fine
      hash = {}
      valid_includes = (self.class.reflect_on_all_associations.map(&:name).map(&:to_s) | self.valid_api_includes)
    
      include_hash = {}
      includes.each do |i| 
        if i.kind_of?(Hash)
          i.each do |k,v|
            include_hash[k.to_s] = v
          end
        else
          include_hash[i.to_s] = []
        end
      end
    
      include_hash.delete_if{|k,v| !valid_includes.include?(k.to_s)}
    
      to_api_attributes.each do |k, v|
        attribute_includes = include_hash[k] || []
        v = v.to_api(*attribute_includes) 
        hash[k] = v
      end

      (include_hash.keys-attributes.keys).each do |relation|
        relation_includes = include_hash[relation] || []
        api_obj = self.send(relation)
        hash[relation.to_s] = api_obj.respond_to?(:to_api) ? api_obj.to_api(*relation_includes) : api_obj
      end
    
      hash
    end

    # override in models
    def valid_api_includes
      []
    end

    def to_api_attributes
      attributes
    end
  end

  #Sadly, Scope isn't enumerable
  class ActiveRecord::NamedScope::Scope
    def to_api(*includes)
      map{|e|e.to_api(*includes)}
    end
  end
end

module Enumerable
  def to_api(*includes)
    map{|e|e.to_api(*includes)}
  end
end

class Fixnum
  def to_api(*includes)
    self
  end
end

class String
  def to_api(*includes)
    self
  end
end

class DateTime
  def to_api(*includes)
    self
  end
end

class Date
  def to_api(*includes)
    self
  end
end

class Time
  def to_api(*includes)
    self
  end
end

class Hash
  def to_api(*includes)
    inject({}) do |memo, (k, v)| 
      memo[k]=v.to_api(*includes)
      memo
    end
  end
end

class Symbol
  def to_api(*includes)
    to_s
  end
end

class NilClass
  def to_api(*includes)
    self
  end
end
