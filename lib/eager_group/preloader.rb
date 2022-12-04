# frozen_string_literal: true

module EagerGroup
  class Preloader
    autoload :AggregationFinder, 'eager_group/preloader/aggregation_finder'
    autoload :HasMany, 'eager_group/preloader/has_many'
    autoload :HasManyThroughBelongsTo, 'eager_group/preloader/has_many_through_belongs_to'
    autoload :HasManyThroughMany, 'eager_group/preloader/has_many_through_many'
    autoload :ManyToMany, 'eager_group/preloader/many_to_many'

    def initialize(klass, records, eager_group_values)
      @klass = klass
      @records = Array.wrap(records).compact.uniq
      eager_group_definitions = @klass.eager_group_definitions
      @eager_group_values = eager_group_values.all? { |value| eager_group_definitions.key?(value) } ? eager_group_values : [eager_group_values]
    end

    # Preload aggregate functions
    def run
      @eager_group_values.each do |eager_group_value|
        definition_key, arguments =
          eager_group_value.is_a?(Array) ? [eager_group_value.shift, eager_group_value] : [eager_group_value, nil]

        if definition_key.is_a?(Hash)
          association_name, definition_key = *definition_key.first
          @records = @records.flat_map { |record| record.send(association_name) }
          next if @records.empty?

          @klass = @records.first.class
        end

        Array.wrap(definition_key).each do |key|
          find_aggregate_values_per_definition!(key, arguments)
        end
      end
    end

    def find_aggregate_values_per_definition!(definition_key, arguments)
      unless definition = @klass.eager_group_definitions[definition_key]
        return
      end

      reflection = @klass.reflect_on_association(definition.association)
      return if reflection.blank?

      aggregation_finder_class = if reflection.is_a?(ActiveRecord::Reflection::HasAndBelongsToManyReflection)
        ManyToMany
      elsif reflection.through_reflection
        if reflection.through_reflection.is_a?(ActiveRecord::Reflection::BelongsToReflection)
          HasManyThroughBelongsTo
        else
          HasManyThroughMany
        end
      else
        HasMany
      end

      aggregation_finder = aggregation_finder_class.new(@klass, definition, arguments, @records)
      aggregate_hash = aggregation_finder.aggregate_hash

      if definition.need_load_object
        aggregate_objects = reflection.klass.find(aggregate_hash.values).each_with_object({}) { |o, h| h[o.id] = o }
        aggregate_hash.keys.each { |key| aggregate_hash[key] = aggregate_objects[aggregate_hash[key]] }
      end

      @records.each do |record|
        id = record.send(aggregation_finder.group_by_key)
        record.send("#{definition_key}=", aggregate_hash[id] || definition.default_value)
      end
    end

    private

    def polymophic_as_condition(reflection)
      reflection.type ? { reflection.name => { reflection.type => @klass.base_class.name } } : []
    end
  end
end
