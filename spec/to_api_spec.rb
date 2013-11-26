require 'spec_helper'

class FakeRecord < ActiveRecord::Base
  belongs_to :associated_record
  belongs_to :other_record
  belongs_to :group
  has_many :child_records

  if respond_to?(:named_scope)
    named_scope :scopez, :conditions => '1=1'
  else
    scope :scopez, :conditions => '1=1'
  end

  attr_accessor :yarg

  def valid_api_includes
    [:associated_record, :other_record]
  end
end

class ChildRecord < ActiveRecord::Base
  belongs_to :category
end

class AssociatedRecord < ActiveRecord::Base
end

class OtherRecord < ActiveRecord::Base
  attr_accessor :foo

  def to_api_attributes
    attributes.merge("foo" => foo)
  end
end

class Category < ActiveRecord::Base
end

describe '#to_api' do
  shared_examples_for "ignoring includes" do
    it "ignores includes" do
      lambda {instance.to_api(['bar']) }.should_not raise_exception
    end
  end

  describe Hash do

    it "returns a new hash with all values to_api'ed" do
      obj1 = double('1', :to_api => "1 to api")
      obj2 = double('2', :to_api => "2 to the api")

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

    it "can have frozen stuff inside it" do
      hash = {
        :key => {:foo => "bar"}
      }
      hash[:key].freeze
      hash.freeze

      hash.to_api.should == {:key => {:foo => "bar"}}.to_api
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

  describe Float do
    it "returns self" do
      foo = 5.5
      foo.to_api.should == foo
    end

    describe "ignoring includes" do
      let(:instance) { 5.5 }
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

  describe TrueClass do
    it "returns self" do
      true.to_api.should == true
    end
    describe "ingoring includes" do
      let(:instance) { true }
      it_should_behave_like "ignoring includes"
    end
  end

  describe FalseClass do
    it "returns self" do
      false.to_api.should == false
    end
    describe "ingoring includes" do
      let(:instance) { false }
      it_should_behave_like "ignoring includes"
    end
  end

  describe 'named scopes' do
    it "returns to_api of the matching records" do
      @base = FakeRecord.create(my_field: "Some Value")
      FakeRecord.scopez.to_api.should == [@base.to_api]
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

    it "can be frozen" do
      a = [["foo"], ["bar"]]
      a.each { |e| e.freeze }
      a.freeze
      a.to_api.should == [["foo"], ["bar"]].to_api
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
        @base.age = 95
        @base.my_field = "why yes"
      end

      it "includes the to_api'd attributes" do
        result = @base.to_api
        result["age"].should == 95
        result["my_field"].should == "why yes"
      end
    end

    describe "with to_api_attributes" do
      before do
        @base = FakeRecord.new
        @base.age = 65
        @base.my_field = "yar"
      end

      it "includes the to_api'd attributes" do
        @base.to_api["age"].should == 65
      end

      it "allows the inclusion of attributes" do
        @base.to_api("my_field")["my_field"].should == 'yar'
      end
    end

    describe "with includes" do
      before do
        @base = FakeRecord.new(:my_field => "some value")
        @base.save!
        @associated_record = @base.create_associated_record("name" => "Joe")
      end

      it "includes the to_api'd attributes" do
        # Without specifying an include the associated_record is not automatically included
        @base.to_api["associated_record"].should be_nil

        # But specify the association and it gets pulled in
        @base.to_api("associated_record")["associated_record"]["name"].should == "Joe"
      end

      it "allows symbols" do
        @base.to_api(:associated_record)["associated_record"]["name"].should == "Joe"
      end

      it "ignores non association includes" do
        @base.yarg = "YYYYARRGG"
        @base.to_api("yarg")["yarg"].should be_nil
      end

      it "allows for explicitly declaring allowable includes" do
        @base.to_api("associated_record")["associated_record"]["name"].should == "Joe"

        # 'group' is not listed in valid_api_includes, so it won't be included even when requested
        @base.to_api("group")["group"].should be_nil
      end

      it "can handle frozen attributes" do
        obj = OtherRecord.new
        obj.foo = ["bar"]
        obj.to_api["foo"].should == ["bar"]

        obj.freeze
        obj.foo.freeze
        obj.to_api["foo"].should == ["bar"]
      end

      it "can handle frozen associations" do
        obj = ChildRecord.new(:name => "a child")
        category = Category.new(:name => "cat 1")
        obj.category = category

        obj.to_api("category")["category"].should == category.to_api

        obj.freeze
        category.freeze
        obj.to_api("category")["category"].should == category.to_api
      end

      describe "versions of params" do

        before do
          @base = FakeRecord.create
          @child = @base.child_records.create(:name => "Jane")
          @child_category = @child.create_category(:name => "Child Category")
          @other_record = @base.create_other_record(:description => "Some Other Record")
        end

        it "only passes includes to the correct objects" do
          @base.to_api("child_records", "foo_records")["child_records"].should == [@child.to_api]
        end

        it "takes a single arg" do
          result = @base.to_api("child_records")
          result["child_records"].should == [@child.to_api]
          result["child_records"].first["category"].should be_nil
          result["other_record"].should be_nil
        end

        it "takes array with singles" do
          result = @base.to_api("child_records", "other_record")
          result["child_records"].should == [@child.to_api]
          result["other_record"].should == @other_record.to_api
        end

        it "takes array with subhash and singles" do
          result = @base.to_api({"child_records" => "category"}, "other_record")
          result["child_records"].should == [@child.to_api("category")]
          result["child_records"].first["category"]["name"].should == @child_category.name
          result["other_record"].should == @other_record.to_api
        end

        it "takes array with subhash as symbols" do
          result = @base.to_api({:child_records => :category}, :other_record)
          result["child_records"].should == [@child.to_api("category")]
          result["child_records"].first["category"]["name"].should == @child_category.name
          result["other_record"].should == @other_record.to_api
        end
      end

      describe "#add_to_api_filter" do
        it "adds a filter" do
          @base = FakeRecord.new(:my_field => "foo")
          @base.add_to_api_filter("my_field") do |parent, child_includes|
            "YO-HO-HO"
          end

          @base.to_api("my_field")["my_field"].should == "YO-HO-HO"
        end

        it "sends filter to child" do
          @base = FakeRecord.create
          @child = @base.child_records.create(:name => "Jane")

          @base.add_to_api_filter("category") do |parent, child_includes|
            "Not the real category"
          end

          result = @base.to_api("child_records" => "category")
          child = result["child_records"].first
          child["name"].should == @child.name
          child["category"].should == "Not the real category"
        end

        it "doesn't blow up when a frozen object gets to_api'd" do
          models = [FakeRecord.new, FakeRecord.new]
          models.freeze

          result = models.to_api
          result.should == [
            models[0].to_api,
            models[1].to_api,
          ]
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

