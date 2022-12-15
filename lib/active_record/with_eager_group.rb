# frozen_string_literal: true

module ActiveRecord
  module WithEagerGroup
    def exec_queries
      records = super
      EagerGroup::Preloader.new(klass, records, eager_group_values).run if eager_group_values.present?
      records
    end

    def eager_group(*args)
      # we does not use the `check_if_method_has_arguments!` here because it would flatten all the arguments,
      # which would cause `[:eager_group_definition, scope_arg1, scope_arg2]` not able to preload together with other `eager_group_definitions`.
      # e.g. `Post.eager_group(:approved_comments_count, [:comments_average_rating_by_author, students[0], true])`
      check_argument_not_blank!(args)

      spawn.eager_group!(*args)
    end

    def eager_group!(*args)
      self.eager_group_values |= args
      self
    end

    def eager_group_values
      @values[:eager_group] || []
    end

    def eager_group_values=(values)
      raise ImmutableRelation if @loaded

      @values[:eager_group] = values
    end

    private

    def check_argument_not_blank!(args)
      raise ArgumentError, "The method .eager_group() must contain arguments." if args.blank?
      args.compact_blank!
    end
  end
end
