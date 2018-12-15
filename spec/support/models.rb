# frozen_string_literal: true

class Post < ActiveRecord::Base
  has_many :comments

  define_eager_group :comments_average_rating, :comments, :average, :rating
  define_eager_group :approved_comments_count, :comments, :count, :*, -> { approved }
  define_eager_group :comments_average_rating_by_author, :comments, :average, :rating, -> (author, ignore) {by_author(author, ignore)}
end

class Comment < ActiveRecord::Base
  belongs_to :post
  belongs_to :author, polymorphic: true

  scope :approved, -> { where(status: 'approved') }
  scope :by_author, -> (author, ignore) {where(author: author)}
end

class Teacher < ActiveRecord::Base
  has_many :classrooms
  has_many :students, through: :classrooms

  define_eager_group :students_count, :students, :count, :*
end

class Student < ActiveRecord::Base
  has_many :classrooms
  has_many :teachers, through: :classrooms
  has_many :comments, as: :author
  has_many :posts, through: :comments

  define_eager_group :posts_count, :posts, :count, "distinct post_id"
end

class Classroom < ActiveRecord::Base
  belongs_to :teacher
  belongs_to :student
end
