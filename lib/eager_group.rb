# frozen_string_literal: true

require 'active_support/core_ext/module/attribute_accessors'
require 'eager_group/version'

module EagerGroup
  autoload :Preloader, 'eager_group/preloader'
  autoload :Definition, 'eager_group/definition'

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    mattr_accessor :eager_group_definitions, default: {}

    # class Post
    #   define_eager_group :comments_avergage_rating, :comments, :average, :rating
    #   define_eager_group :approved_comments_count, :comments, :count, :*, -> { approved }
    # end
    def define_eager_group(attr, association, aggregate_function, column_name, scope = nil)
      send :attr_accessor, attr
      eager_group_definitions[attr] = Definition.new(association, aggregate_function, column_name, scope)

      define_method attr,
                    lambda { |*args|
                      query_result_cache = instance_variable_get("@#{attr}")
                      return query_result_cache if args.blank? && query_result_cache.present?

                      preload_eager_group(attr, *args)
                      instance_variable_get("@#{attr}")
                    }

      define_method "#{attr}=" do |val|
        instance_variable_set("@#{attr}", val)
      end
    end
  end

  private

  def preload_eager_group(*eager_group_value)
    EagerGroup::Preloader.new(self.class, [self], [eager_group_value]).run
  end
end

require 'active_record'
ActiveRecord::Base.class_eval do
  include EagerGroup
  class << self
    delegate :eager_group, to: :all
  end
end
require 'active_record/with_eager_group'
ActiveRecord::Relation.prepend ActiveRecord::WithEagerGroup
