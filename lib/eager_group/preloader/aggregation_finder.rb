module EagerGroup
  class Preloader
    class AggregationFinder
      attr_reader :klass, :reflection, :definition, :arguments, :record_ids

      def initialize(klass, definition, arguments, records)
        @klass = klass
        @definition = definition
        @reflection = @klass.reflect_on_association(definition.association)
        @arguments = arguments
        @records = records
      end

      def definition_scope
        reflection.klass.instance_exec(*arguments, &definition.scope) if definition.scope
      end

      def record_ids
        @record_ids ||= @records.map { |record| record.send(group_by_key) }
      end

      def group_by_key
        @klass.primary_key
      end

      private

      def polymophic_as_condition
        reflection.type ? { reflection.name => { reflection.type => @klass.base_class.name } } : []
      end
    end
  end
end
