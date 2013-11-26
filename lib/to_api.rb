module ToApiSelf
  def to_api(*includes)
    self
  end
end
[ Numeric, String, DateTime, Date, Time, NilClass, TrueClass, FalseClass ].each do |klass|
  klass.send(:include, ToApiSelf)
end

module ToApiInstanceMethods
  def build_to_api_include_hash(*includes)
    include_hash = {}
    includes.each do |i|
      if i.kind_of?(Hash)
        i.each do |k,v|
          include_hash[k] = v
        end
      else
        include_hash[i] = []
      end
    end
    include_hash
  end
end

module ToApiFilter
  def add_to_api_filter(include_name, &block)
    @_to_api_filters ||= {}
    @_to_api_filters[include_name] = block
  end

  def to_api_filters=(filters)
    @_to_api_filters = filters
  end

  def to_api_filters
    if frozen?
      @_to_api_filters || {}
    else
      @_to_api_filters ||= {}
    end
  end
end

if Object.const_defined? :ActiveRecord

  class ActiveRecord::Base
    include ToApiFilter

    def to_api(*includes) #assumes all attribute types are fine
      hash = {}
      valid_includes = (self.class.reflect_on_all_associations.map(&:name).map(&:to_s) | self.valid_api_includes | self.attributes.keys)

      include_hash = build_to_api_ar_include_hash(*includes)
      include_hash.keys.each do |inc|
        if to_api_filters.has_key?(inc)
          child_includes = include_hash.delete(inc) || []
          hash[inc] = to_api_filters[inc].call self, child_includes
        end
      end

      include_hash.delete_if{|k,v| !valid_includes.include?(k.to_s)}
      to_api_attributes.each do |k, v|
        unless hash[k]
          v.to_api_filters = to_api_filters if to_api_filters.any? && v.respond_to?(:to_api_filters)

          attribute_includes = include_hash[k] || []
          to_api_v = v.to_api(*[attribute_includes].flatten.compact)
          hash[k] = to_api_v
        end
      end

      (include_hash.keys-to_api_attributes.keys).each do |relation|
        unless hash[relation]
          relation_includes = include_hash[relation] || []
          api_obj = self.send(relation)
          api_obj.to_api_filters = to_api_filters if api_obj.respond_to?(:to_api_filters)

          hash[relation.to_s] = api_obj.respond_to?(:to_api) ? api_obj.to_api(*[relation_includes].flatten.compact) : api_obj
        end
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

    private
    def build_to_api_ar_include_hash(*includes)
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
      include_hash
    end

  end

  if defined?(ActiveRecord::NamedScope)
    #Sadly, Scope isn't enumerable
    class ActiveRecord::NamedScope::Scope
      include ToApiFilter
      def to_api(*includes)
        map{|e|
          e.to_api_filters = to_api_filters if to_api_filters.any? && e.respond_to?(:to_api_filters)
          e.to_api_filters = to_api_filters if e.respond_to?(:to_api_filters)
          e.to_api(*includes)
        }
      end
    end
  end
end

class Array
  include ToApiFilter
  def to_api(*includes)
    map{|e|
      e.to_api_filters = to_api_filters if to_api_filters.any? && e.respond_to?(:to_api_filters)

      e.to_api(*includes)
    }
  end
end

class Hash
  include ToApiFilter
  include ToApiInstanceMethods
  def to_api(*includes)
    values = {}

    include_hash = build_to_api_include_hash(*includes)

    include_hash.keys.each do |inc|
      if to_api_filters.has_key?(inc)
        child_includes = include_hash[inc]
        values[inc] = to_api_filters[inc].call self, child_includes
      end
    end

    (keys-values.keys).each do |k|
      val = self[k]
      val.to_api_filters = to_api_filters if to_api_filters.any? && val.respond_to?(:to_api_filters)
      child_includes = include_hash[k] || []
      values[k] = val.to_api(*[child_includes].flatten.compact)
    end
    values
  end
end

class Symbol
  def to_api(*includes)
    to_s
  end
end

