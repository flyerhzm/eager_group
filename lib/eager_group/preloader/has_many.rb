module EagerGroup
  class Preloader
    class HasMany < AggregationFinder
      def group_by_foreign_key
        reflection.foreign_key
      end

      def aggregate_hash
        scope = reflection.klass.all.tap{|query| query.merge!(definition_scope) if definition_scope }

        scope.where(group_by_foreign_key => record_ids).
          where(polymophic_as_condition).
          group(group_by_foreign_key).
          send(definition.aggregation_function, definition.column_name)
      end
    end
  end
end
