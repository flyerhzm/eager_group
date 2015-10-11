module EagerGroup
  class Preloader
    def initialize(klass, records, eager_group_values)
      @klass = klass
      @records = Array.wrap(records).compact.uniq
      @eager_group_values = eager_group_values
    end

    # Preload aggregate functions
    def run
      primary_key = @klass.primary_key
      record_ids = @records.map { |record| record.send primary_key }
      @eager_group_values.each do |eager_group_value|
        definition = @klass.eager_group_definations[eager_group_value]
        if definition
          reflection = @klass.reflect_on_association(definition.association)
          association_class = reflection.class_name.constantize
          association_class = association_class.instance_exec(&definition.scope) if definition.scope
          if reflection.through_reflection
            foreign_key = "#{reflection.through_reflection.name}.#{reflection.through_reflection.foreign_key}"
            as_where_condition = if reflection.through_reflection.options[:as]
              # After Rails 4.0. STI use base_class as polymorphic type
              ["#{reflection.through_reflection.options[:as]}_type = ?", @klass.base_class.name]
            else
              []
            end
            aggregate_hash = association_class.joins(reflection.through_reflection.name)
                                              .where("#{foreign_key} IN (?)", record_ids)
                                              .where(as_where_condition)
                                              .group("#{foreign_key}")
                                              .send(definition.aggregate_function, definition.column_name)
          else
            aggregate_hash = association_class.where(reflection.foreign_key => record_ids)
                                              .group(reflection.foreign_key)
                                              .send(definition.aggregate_function, definition.column_name)
          end
          @records.each do |record|
            id = record.send primary_key
            record.send "#{eager_group_value}=", aggregate_hash[id] || 0
          end
        end
      end
    end
  end
end
