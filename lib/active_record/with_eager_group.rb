# frozen_string_literal: true

module ActiveRecord
  module WithEagerGroup
    def exec_queries
      records = super
      EagerGroup::Preloader.new(klass, records, eager_group_values).run if eager_group_values.present?
      records
    end

    def eager_group(*args)
      raise ArgumentError, "The method .eager_group() must contain arguments." if args.blank?
      args.compact_blank!

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
  end
end
