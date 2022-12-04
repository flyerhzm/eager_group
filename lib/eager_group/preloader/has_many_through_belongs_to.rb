module EagerGroup
  class Preloader
    class HasManyThroughBelongsTo < AggregationFinder
      def group_by_foreign_key
        "#{reflection.table_name}.#{reflection.through_reflection.klass.reflect_on_association(reflection.name).foreign_key}"
      end

      def aggregate_hash
        scope = reflection.klass.all.tap{|query| query.merge!(definition_scope) if definition_scope }

        scope.where(group_by_foreign_key => record_ids).
          where(polymophic_as_condition).
          group(group_by_foreign_key).
          send(definition.aggregation_function, definition.column_name)
      end

      def group_by_key
        reflection.through_reflection.foreign_key
      end

      def polymophic_as_condition
        reflection.type ? { reflection.name => { reflection.type => reflection.through_reflection.klass.base_class.name } } : []
      end
    end
  end
end
