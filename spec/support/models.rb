class Post < ActiveRecord::Base
  has_many :comments

  define_eager_group :comments_average_rating, :comments, :average, :rating
  define_eager_group :approved_comments_count, :comments, :count, :*, -> { approved }
end

class Comment < ActiveRecord::Base
  belongs_to :post

  scope :approved, -> { where(status: 'approved') }
end
