require "eager_group/version"
require 'active_record'
require 'eager_group/active_record_base'
require 'eager_group/active_record_relation'

module EagerGroup
  autoload :Preloader, 'eager_group/preloader'
  autoload :Definition, 'eager_group/definition'

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    attr_reader :eager_group_definations

    # class Post
    #   define_eager_group :comments_avergage_rating, :comments, :average, :rating
    #   define_eager_group :approved_comments_count, :comments, :count, :*, -> { approved }
    # end
    def define_eager_group(attr, association, aggregate_function, column_name, scope = nil)
      self.send :attr_accessor, attr
      @eager_group_definations ||= {}
      @eager_group_definations[attr] = Definition.new association, aggregate_function, column_name, scope
    end
  end
end

ActiveRecord::Base.send :include, EagerGroup
