# frozen_string_literal: true

# Calculating -------------------------------------
#   Without EagerGroup     2.000  i/100ms
#      With EagerGroup    28.000  i/100ms
# -------------------------------------------------
#   Without EagerGroup     28.883  (± 6.9%) i/s -    144.000
#      With EagerGroup    281.755  (± 5.0%) i/s -      1.428k
#
# Comparison:
#      With EagerGroup:      281.8 i/s
#   Without EagerGroup:       28.9 i/s - 9.76x slower
$: << 'lib'
require 'benchmark/ips'
require 'active_record'
require 'activerecord-import'
require 'eager_group'

class Post < ActiveRecord::Base
  has_many :comments

  define_eager_group :comments_average_rating, :comments, :average, :rating
  define_eager_group :approved_comments_count, :comments, :count, :*, -> { approved }
end

class Comment < ActiveRecord::Base
  belongs_to :post

  scope :approved, -> { where(status: 'approved') }
end

# create database eager_group_benchmark;
ActiveRecord::Base.establish_connection(:adapter => 'mysql2', :database => 'eager_group_benchmark', :server => '/tmp/mysql.socket', :username => 'root')

ActiveRecord::Base.connection.tables.each do |table|
  ActiveRecord::Base.connection.drop_table(table)
end

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :posts, :force => true do |t|
    t.string :title
    t.string :body
    t.timestamps null: false
  end

  create_table :comments, :force => true do |t|
    t.string :body
    t.string :status
    t.integer :rating
    t.integer :post_id
    t.timestamps null: false
  end
end

posts_size = 100
comments_size = 1000

posts = []
posts_size.times do |i|
  posts << Post.new(:title => "Title #{i}", :body => "Body #{i}")
end
Post.import posts
post_ids = Post.all.pluck(:id)

comments = []
comments_size.times do |i|
  comments << Comment.new(:body => "Comment #{i}", :post_id => post_ids[i % 100], :status => ["approved", "deleted"][i % 2], rating: i % 5 + 1)
end
Comment.import comments

Benchmark.ips do |x|
  x.report("Without EagerGroup") do
    Post.limit(20).each do |post|
      post.comments.approved.count
      post.comments.approved.average('rating')
    end
  end

  x.report("With EagerGroup") do
    Post.eager_group(:approved_comments_count, :comments_average_rating).limit(20).each do |post|
      post.approved_comments_count
      post.comments_average_rating
    end
  end

  x.compare!
end
