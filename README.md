# EagerGroup

[![Build Status](https://secure.travis-ci.org/flyerhzm/eager_group.png)](http://travis-ci.org/flyerhzm/eager_group)
[![AwesomeCode Status for
flyerhzm/eager_group](https://awesomecode.io/projects/e5386790-9420-4003-831a-c9a8c8a48108/status)](https://awesomecode.io/repos/flyerhzm/eager_group)

[More explaination on our blog](http://blog.flyerhzm.com/2015/06/29/eager_group/)

Fix n+1 aggregate sql functions for rails, like

    SELECT "posts".* FROM "posts";
    SELECT COUNT(*) FROM "comments" WHERE "comments"."post_id" = 1 AND "comments"."status" = 'approved'
    SELECT COUNT(*) FROM "comments" WHERE "comments"."post_id" = 2 AND "comments"."status" = 'approved'
    SELECT COUNT(*) FROM "comments" WHERE "comments"."post_id" = 3 AND "comments"."status" = 'approved'

=>

    SELECT "posts".* FROM "posts";
    SELECT COUNT(*) AS count_all, post_id AS post_id FROM "comments" WHERE "comments"."post_id" IN (1, 2, 3) AND "comments"."status" = 'approved' GROUP BY post_id;

or

    SELECT "posts".* FROM "posts";
    SELECT AVG("comments"."rating") AS avg_id FROM "comments" WHERE "comments"."post_id" = 1;
    SELECT AVG("comments"."rating") AS avg_id FROM "comments" WHERE "comments"."post_id" = 2;
    SELECT AVG("comments"."rating") AS avg_id FROM "comments" WHERE "comments"."post_id" = 3;

=>

    SELECT "posts".* FROM "posts";
    SELECT AVG("comments"."rating") AS average_comments_rating, post_id AS post_id FROM "comments" WHERE "comments"."post_id" IN (1, 2, 3) GROUP BY post_id;

It supports Rails 4.x and Rails 5.x

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'eager_group'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install eager_group

## Usage

First you need to define what aggregate function you want to eager
load.

    class Post < ActiveRecord::Base
      has_many :comments

      define_eager_group :comments_average_rating, :comments, :average, :rating
      define_eager_group :approved_comments_count, :comments, :count, :*, -> { approved }
    end

    class Comment < ActiveRecord::Base
      belongs_to :post

      scope :approved, -> { where(status: 'approved') }
    end

The parameters for `define_eager_group` are as follows

* `definition_name`, it's used to be a reference in `eager_group` query
method, it also generates a method with the same name to fetch the
result.
* `association`, association name you want to aggregate.
* `aggregate_function`, aggregate sql function, can be one of `average`,
`count`, `maximum`, `minimum`, `sum`.
* `column_name`, aggregate column name, it can be `:*` for `count`
* `scope`, scope is optional, it's used to filter data for aggregation.

Then you can use `eager_group` to fix n+1 aggregate sql functions
when querying

    posts = Post.all.eager_group(:comments_average_rating, :approved_comments_count)
    posts.each do |post|
      post.comments_average_rating
      post.approved_comments_count
    end

EagerGroup will execute `GROUP BY` sqls for you then set the value of
attributes.

`define_eager_group` will define a method in model.
You can call the `definition_name` directly for convenience,
but it would not help you to fix n+1 aggregate sql issue.

    post = Post.first
    post.commets_average_rating
    post.approved_comments_count

## Advanced

   User.limit(10).includes(:posts).eager_group(posts: [:comments_average_rating, :approved_comments_count])

## Benchmark

I wrote a benchmark script [here][1], it queries approved comments count
and comments average rating for 20 posts, with eager group, it gets 10
times faster, WOW!

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/flyerhzm/eager_group.

[1]:  https://github.com/flyerhzm/eager_group/blob/master/benchmark.rb
