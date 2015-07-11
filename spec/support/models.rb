class Post < ActiveRecord::Base
  has_many :comments

  define_eager_group :comments_average_rating, :comments, :average, :rating
  define_eager_group :approved_comments_count, :comments, :count, :*, -> { approved }
end

class Comment < ActiveRecord::Base
  belongs_to :post

  scope :approved, -> { where(status: 'approved') }
end

class Teacher < ActiveRecord::Base
  has_many :classrooms
  has_many :students, through: :classrooms

  define_eager_group :students_count, :students, :count, :*
end

class Student < ActiveRecord::Base
  has_many :classrooms
  has_many :teachers, through: :classrooms
end

class Classroom < ActiveRecord::Base
  belongs_to :teacher
  belongs_to :student
end
