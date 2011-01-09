Description
===========

A lightweight, format-agnostic API transformation gem.

Synopsis
========

Models shouldn't know about formats. Controllers shouldn't know what attributes your domain objects have. It should be trivial to serve the same data in multiple formats.

### How do I use it?

Implement to_api on your data objects to return a hash with all needed attributes.

    class Person
      attr_accessor :first_name, :last_name, :secret
  
      def to_api
        {:first_name => @first_name, :last_name => @last_name}.to_api
      end
    end
    
    class Group
      attr_accessor :name, :description, :people
      
      def to_api
        {:name => @name, :description => @description, :people => @people}.to_api
      end
    end

Now just call your to\_api method. You'll get back a hash of arrays, hashes, strings, numbers, and nil. All of these are very easily converted to a format of your choice.

    JSON.generate(group.to_api)
    
### If I have to implement to\_api, what does the gem do for me?

The gem provides to\_api for common Ruby classes, allowing simple conversion to json, xml, yaml, etc. Hash and Enumerable transform all their contents, allowing your data objects to simply call to\_api on a hash of relevant attributes.

Fixnum, String, DateTime, Symbol, and NilClass are also provided.

### What about Ruby on Rails?

If ActiveRecord is present, ActiveRecord::Base#to\_api transforms and returns the attributes hash. It also supports an :includes option that mirrors the ActiveRecord finder usage.

    person.to_api([{:groups => :members}, :interests])

### What if I need support for other common classes?

For most classes, it only takes a couple specs and a few lines of code. Send a pull request; we'd love to take your additions.

Authors
=======

* Ryan Fogle (fogle@atomicobject.com)
* Shawn Anderson (shawn.anderson@atomicobject.com)
* © 2011 [Atomic Object](http://www.atomicobject.com/)
* More Atomic Object [open source](http://www.atomicobject.com/pages/Software+Commons) projects
