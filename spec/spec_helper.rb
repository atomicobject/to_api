require "rubygems"
require "bundler/setup"
require 'rspec'
require 'active_record'
require 'pry'
require 'to_api'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => ':memory:'
)

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :fake_records, :force => true do |t|
    t.integer :age
    t.string :my_field
    t.integer :associated_record_id
    t.integer :other_record_id
    t.integer :group_id
  end

  create_table :associated_records, :force => true do |t|
    t.string :name
  end

  create_table :other_records, :force => true do |t|
    t.string :description
  end

  create_table :groups, :force => true do |t|
    t.string :group_name
  end

  create_table :child_records, :force => true do |t|
    t.integer :fake_record_id
    t.string :name
    t.integer :category_id
  end

  create_table :categories, :force => true do |t|
    t.string :name
  end
end

RSpec.configure do |config|
end
