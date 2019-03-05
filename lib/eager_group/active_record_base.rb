# frozen_string_literal: true

class ActiveRecord::Base
  class << self
    # Post.eager_group(:approved_comments_count, :comments_average_rating)
    delegate :eager_group, to: :all
  end
end
