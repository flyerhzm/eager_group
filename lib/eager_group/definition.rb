# frozen_string_literal: true

module EagerGroup
  class Definition
    attr_reader :association, :column_name, :scope

    def initialize(association, aggregate_function, column_name, scope)
      @association = association
      @aggregate_function = aggregate_function
      @column_name = column_name
      @scope = scope
    end

    def aggregation_function
      return :maximum if @aggregate_function.to_sym == :last_object
      return :minimum if @aggregate_function.to_sym == :first_object
      @aggregate_function
    end

    def need_load_object
      %i[first_object last_object].include?(@aggregate_function.to_sym)
    end

    def default_value
      %i[first_object last_object].include?(@aggregate_function.to_sym) ? nil : 0
    end
  end
end
