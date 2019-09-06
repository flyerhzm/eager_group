# frozen_string_literal: true

class User < ActiveRecord::Base
  has_many :posts
end

class Post < ActiveRecord::Base
  belongs_to :user
  has_many :comments

  define_eager_group :comments_average_rating, :comments, :average, :rating
  define_eager_group :approved_comments_count,
                     :comments,
                     :count,
                     :*,
                     -> { approved }
  define_eager_group :comments_average_rating_by_author,
                     :comments,
                     :average,
                     :rating,
                     ->(author, ignore) { by_author(author, ignore) }
  define_eager_group :first_comment, :comments, :first_object, :id
  define_eager_group :last_comment, :comments, :last_object, :id
end

class Comment < ActiveRecord::Base
  belongs_to :post
  belongs_to :author, polymorphic: true

  scope :approved, -> { where(status: 'approved') }
  scope :by_author, ->(author, _ignore) { where(author: author) }
end

class Teacher < ActiveRecord::Base
  has_many :classrooms
  has_many :students, through: :classrooms
  has_many :homeworks

  define_eager_group :students_count, :students, :count, :*
end

class Student < ActiveRecord::Base
  has_many :classrooms
  has_many :teachers, through: :classrooms
  has_many :comments, as: :author
  has_many :posts, through: :comments
  has_many :homeworks

  define_eager_group :posts_count, :posts, :count, 'distinct post_id'
end

class Classroom < ActiveRecord::Base
  belongs_to :teacher
  belongs_to :student
end

class Homework < ActiveRecord::Base
  belongs_to :teacher
  belongs_to :student

  define_eager_group :students_count, :students, :count, '*'
end
