# frozen_string_literal: true

module ActiveRecord
  module WithEagerGroup
    def exec_queries
      records = super
      if eager_group_values.present?
        EagerGroup::Preloader.new(self.klass, records, eager_group_values).run
      end
      records
    end

    def eager_group(*args)
      check_if_method_has_arguments!('eager_group', args)
      spawn.eager_group!(*args)
    end

    def eager_group!(*args)
      self.eager_group_values += args
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
