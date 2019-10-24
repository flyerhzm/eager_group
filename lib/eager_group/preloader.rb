# frozen_string_literal: true

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
      @eager_group_values.each do |eager_group_value|
        definition_key, arguments =
          eager_group_value.is_a?(Array) ? [eager_group_value.shift, eager_group_value] : [eager_group_value, nil]

        if definition_key.is_a?(Hash)
          association_name, definition_key = *definition_key.first
          @records = @records.flat_map { |record| record.send(association_name) }
          next if @records.empty?

          @klass = @records.first.class
        end
        record_ids = @records.map { |record| record.send(primary_key) }
        unless definition = @klass.eager_group_definitions[definition_key]
          next
        end

        reflection = @klass.reflect_on_association(definition.association)
        association_class = reflection.klass
        association_class = association_class.instance_exec(*arguments, &definition.scope) if definition.scope

        if reflection.is_a?(ActiveRecord::Reflection::HasAndBelongsToManyReflection)
          foreign_key = "#{reflection.join_table}.#{reflection.foreign_key}"
          aggregate_hash = @klass.joins(reflection.name)
        elsif reflection.through_reflection
          foreign_key = "#{reflection.through_reflection.name}.#{reflection.through_reflection.foreign_key}"
          aggregate_hash = @klass.joins(reflection.name)
        else
          foreign_key = reflection.foreign_key
          aggregate_hash = association_class
        end
        aggregate_hash = aggregate_hash.where(foreign_key => record_ids)
                                       .where(polymophic_as_condition(reflection))
                                       .group(foreign_key)
                                       .send(definition.aggregation_function, definition.column_name)
        if definition.need_load_object
          aggregate_objects = reflection.klass.find(aggregate_hash.values).each_with_object({}) { |o, h| h[o.id] = o }
          aggregate_hash.keys.each { |key| aggregate_hash[key] = aggregate_objects[aggregate_hash[key]] }
        end
        @records.each do |record|
          id = record.send(primary_key)
          record.send("#{definition_key}=", aggregate_hash[id] || definition.default_value)
        end
      end
    end

    private

    def polymophic_as_condition(reflection)
      reflection.type ? { reflection.name => { reflection.type => @klass.base_class.name } } : []
    end
  end
end
