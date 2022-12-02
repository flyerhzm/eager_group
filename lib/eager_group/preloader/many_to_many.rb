module EagerGroup
  class Preloader
    class ManyToMany < AggregationFinder
      def group_by_foreign_key
        "#{reflection.join_table}.#{reflection.foreign_key}"
      end

      def aggregate_hash
        scope = klass.joins(reflection.name).tap{|query| query.merge!(definition_scope) if definition_scope}

        scope.where(group_by_foreign_key => record_ids).
          where(polymophic_as_condition).
          group(group_by_foreign_key).
          send(definition.aggregation_function, definition.column_name)
      end
    end
  end
end
