require 'spec_helper'

class FakeRecord < ActiveRecord::Base
  def attributes;{};end
  def attributes_from_column_definition;[];end
  def self.columns_hash;{};end
  named_scope :scopez, :conditions => '1=1'
end

class OtherFakeRecord < FakeRecord
  def attributes;{"my_field"=>''};end
  def my_field;'yar';end
end

class FakeChildRecord < FakeRecord
end

describe '#to_api' do
  shared_examples_for "ignoring includes" do
    it "ignores includes" do
      lambda {instance.to_api(['bar']) }.should_not raise_exception
    end
  end

  describe Hash do

    it "returns a new hash with all values to_api'ed" do
      obj1 = stub('1', :to_api => "1 to api")
      obj2 = mock('2', :to_api => "2 to the api")

      hash = {:one => obj1, :two => obj2}
      hash.to_api.should == {
          :one => "1 to api",
          :two => "2 to the api",
      }
    end

    it "passes on includes" do
      a = "a"
      a.should_receive(:to_api).with('bar').and_return(:apiz)
      {:one => a}.to_api(:one => ['bar']).should == {:one => :apiz}
    end
  end

  describe String do
    it "returns self" do
      foo = "thequickbrownfoxjumpsoverthelazydog"
      foo.to_api.should == foo
    end
    describe "ingoring includes" do
      let(:instance) { "foo" }
      it_should_behave_like "ignoring includes"
    end

  end

  describe Integer do
    it "returns self" do
      foo = 8
      foo.to_api.should == foo
    end
    describe "ingoring includes" do
      let(:instance) { 8 }
      it_should_behave_like "ignoring includes"
    end

  end

  describe Symbol do
    it "returns string of sym" do
      :foo.to_api.should == "foo"
    end
    describe "ingoring includes" do
      let(:instance) { :foo }
      it_should_behave_like "ignoring includes"
    end

  end

  describe DateTime do
    it "returns self" do
      now = DateTime.now
      now.to_api.should == now
    end
    describe "ingoring includes" do
      let(:instance) { DateTime.now }
      it_should_behave_like "ignoring includes"
    end
  end

  describe Date do 
    it "returns self" do
      now = Date.today
      now.to_api.should == now
    end
    describe "ignoring includes" do
      let(:instance){ Date.today }
      it_should_behave_like "ignoring includes"
    end
  end

  describe Time do
    it "returns self" do
      now = Time.now
      now.to_api.should == now
    end
    describe "ingoring includes" do
      let(:instance) { Time.now }
      it_should_behave_like "ignoring includes"
    end
  end

  describe ActiveRecord::NamedScope::Scope do
    it "returns to_api of its kids" do
      FakeRecord.should_receive(:reflect_on_all_associations).and_return([mock(:name => "fake_child_records")])
      @base = FakeRecord.new
      @base.should_receive(:fake_child_records).and_return([{"foo" => "bar"}])

      FakeRecord.stub!(:find_every => [@base])
      FakeRecord.scopez.to_api("fake_child_records").should == [{"fake_child_records" => [{"foo" => "bar"}]}]
    end
  end

  describe Array do
    it "returns to_api of its kids" do
      a = "a"
      a.should_receive(:to_api).and_return(:apiz)
      [a].to_api.should == [:apiz]
    end

    it "explodes on non-to_api-able kids" do
      lambda { [/boom/].to_api }.should raise_exception
    end

    it "passes on includes" do
      a = "a"
      a.should_receive(:to_api).with(['bar']).and_return(:apiz)
      [a].to_api(['bar']).should == [:apiz]
    end
  end
  
  describe nil do
    it "returns nil" do
      nil.to_api.should be_nil
      nil.to_api("args","not","used").should be_nil
    end
  end

  describe ActiveRecord::Base do

    describe "with attributes" do
      before do
        @base = FakeRecord.new
        @base.stub!(:attributes => {"age" => mock(:to_api => :apid_age)})
      end

      it "includes the to_api'd attributes" do
        @base.to_api["age"].should == :apid_age
      end
    end

    describe "with to_api_attributes" do
      before do
        @base = OtherFakeRecord.new
        @base.stub!(:to_api_attributes => {"age" => mock(:to_api => :apid_age)})
      end

      it "includes the to_api'd attributes" do
        @base.to_api["age"].should == :apid_age
      end

      it "allows the inclusion of attributes" do
        @base.to_api("my_field")["my_field"].should == 'yar'
      end
    end

    describe "with includes" do
      before do
        @base = FakeRecord.new
        @base.stub!(:attributes => {})
        FakeRecord.stub!(:reflect_on_all_associations => [mock(:name => "foopy_pantz")])
        @base.stub!(:foopy_pantz => "pantz of foop")
      end

      it "includes the to_api'd attributes" do
        @base.to_api("foopy_pantz")["foopy_pantz"].should == "pantz of foop"
      end
      
      it "allows symbols" do
        @base.to_api(:foopy_pantz)["foopy_pantz"].should == "pantz of foop"
      end
      
      it "ignores non association includes" do
        @base.stub!(:yarg => "YYYYARRGG")
        @base.to_api("yarg")["yarg"].should be_nil
      end
      
      it "allows for explicitly declaring allowable includes" do
        @base.stub!(:foo => "FOO")
        @base.stub!(:valid_api_includes => ["foo"])
        @base.to_api("foo")["foo"].should == "FOO"
      end
      
      describe "versions of params" do
      
        before do
          FakeChildRecord.stub!(:reflect_on_all_associations => [mock(:name => "foopy_pantz")])
          @child = FakeChildRecord.new
          @child.stub!(:foopy_pantz => "pantz of foop")
  
          FakeRecord.should_receive(:reflect_on_all_associations).and_return([mock(:name => "fake_child_records"), mock(:name => "other_relation")])  
          @base = FakeRecord.new
          
          @base.should_receive(:fake_child_records).and_return([@child])
          @other_child = mock(:to_api => {"foo"=>"bar"})
        end
        
        it "only passes includes to the correct objects" do
          @child.should_receive(:to_api).with().and_return({})
          @base.to_api("fake_child_records","foopy_pantz").should == {"fake_child_records" => [{}]}
        end
        
        
        it "takes a single arg" do
          @child.should_receive(:to_api).with().and_return({})
          @base.to_api("fake_child_records").should == {"fake_child_records" => [{}]}
        end
        
        it "takes array with singles" do
          @child.should_receive(:to_api).with().and_return({})
          @base.to_api("fake_child_records","foopy_pantz").should == {"fake_child_records" => [{}]}
        end
        
        it "takes array with subhash" do
          @child.should_receive(:to_api).with("foopy_pantz").and_return({})
          @base.should_receive(:other_relation).and_return(@other_child)
          @base.to_api({"fake_child_records" => "foopy_pantz"}, "other_relation").should == {"fake_child_records" => [{}], "other_relation" => {"foo"=>"bar"}}
        end

        it "takes array with subhash as symbols" do
          @child.should_receive(:to_api).with(:foopy_pantz).and_return({})
          @base.should_receive(:other_relation).and_return(@other_child)
          @base.to_api({:fake_child_records => :foopy_pantz}, :other_relation).should == {"fake_child_records" => [{}], "other_relation" => {"foo"=>"bar"}}
        end        

        it "takes array with singles and subhashes" do
          @child.should_receive(:to_api).with("foopy_pantz").and_return({})
          @base.to_api("fake_child_records" => "foopy_pantz").should == {"fake_child_records" => [{}]}
        end
      end

      describe "#add_to_api_filter" do
        it "adds a filter" do
          @base = OtherFakeRecord.new
          @base.should_not_receive(:my_field)
          @base.add_to_api_filter("my_field") do |parent, child_includes|
            "YO-HO-HO"
          end

          @base.to_api("my_field")["my_field"].should == "YO-HO-HO"
        end

        it "sends filter to child" do
          FakeRecord.stub!(:reflect_on_all_associations => [mock(:name => "kids")])
          FakeChildRecord.stub!(:reflect_on_all_associations => [mock(:name => "foopy_pantz")])

          @base = FakeRecord.new
          @base.stub!(:attributes => {})

          @child = FakeChildRecord.new

          @child.stub!(:foopy_pantz => "pantz of foop")
          
          @base.should_receive(:kids).and_return([@child])

          @base.add_to_api_filter("foopy_pantz") do |parent, child_includes|
            "kachaa"
          end

          @base.to_api("kids" => "foopy_pantz").should == {"kids" => [{"foopy_pantz" => "kachaa"}]}
        end
      end
    end
  end

  describe "#add_to_api_filter" do
    before do
      @subhash = {:b => :c, :d => :e}
      @hash = {:a => @subhash}
    end

    it "puts blocks return value in for filtered key" do
      @hash.add_to_api_filter("count") do |parent, child_includes|
        @hash.count
      end

      @hash.to_api("count")["count"].should == 1
    end

    it "nests hashes with filters" do
      @hash.add_to_api_filter("id") do |parent, child_includes|
        parent.object_id
      end

      api_object = @hash.to_api({"id" => "", :a => "id"})
      api_object["id"].should == @hash.object_id
      api_object[:a]["id"].should == @subhash.object_id
    end

    it "nests hashes of hashes with filters" do
      @hash.add_to_api_filter("id") do |parent, child_includes|
        parent.object_id
      end

      api_object = @hash.to_api({"id" => "", :a => {"id" => ""}})
      api_object["id"].should == @hash.object_id
      api_object[:a]["id"].should == @subhash.object_id
    end

    it "nests hashes with filters with hash params" do
      @hash.add_to_api_filter("id") do |parent, child_includes|
        parent.object_id
      end

      api_object = @hash.to_api(:a => "id")
      api_object["id"].should be_nil
      api_object[:a]["id"].should == @subhash.object_id
    end
  end
end

