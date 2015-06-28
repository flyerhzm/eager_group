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
          reflect = @klass.reflect_on_association(definition.association)
          association_class = reflect.class_name.constantize
          association_class = association_class.instance_exec(&definition.scope) if definition.scope
          aggregate_hash = association_class.where(reflect.foreign_key => record_ids)
                                            .group(reflect.foreign_key)
                                            .send(definition.aggregate_function, definition.column_name)
          @records.each do |record|
            id = record.send primary_key
            record.send "#{eager_group_value}=", aggregate_hash[id]
          end
        end
      end
    end
  end
end
