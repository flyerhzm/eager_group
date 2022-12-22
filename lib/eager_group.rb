# frozen_string_literal: true

require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/hash'
require 'eager_group/version'

module EagerGroup
  autoload :Preloader, 'eager_group/preloader'
  autoload :Definition, 'eager_group/definition'

  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      class_attribute :eager_group_definitions, instance_writer: false, default: {}.with_indifferent_access
    end
  end

  module ClassMethods
    #mattr_accessor :eager_group_definitions, default: {}

    def add_eager_group_definition(ar, definition_name, definition)
      ar.eager_group_definitions = self.eager_group_definitions.except(definition_name).merge!(definition_name => definition)
    end

    # class Post
    #   define_eager_group :comments_avergage_rating, :comments, :average, :rating
    #   define_eager_group :approved_comments_count, :comments, :count, :*, -> { approved }
    # end
    def define_eager_group(attr, association, aggregate_function, column_name, scope = nil)
      add_eager_group_definition(self, attr, Definition.new(association, aggregate_function, column_name, scope))
      define_definition_accessor(attr)
    end

    def define_definition_accessor(definition_name)
      define_method definition_name,
                    lambda { |*args|
                      query_result_cache = instance_variable_get("@#{definition_name}")
                      return query_result_cache if args.blank? && query_result_cache.present?

                      preload_eager_group(definition_name, *args)
                      instance_variable_get("@#{definition_name}")
                    }

      define_method "#{definition_name}=" do |val|
        instance_variable_set("@#{definition_name}", val)
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
