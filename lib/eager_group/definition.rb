module EagerGroup
  class Definition
    attr_reader :association, :aggregate_function, :column_name, :scope

    def initialize(association, aggregate_function, column_name, scope)
      @association = association
      @aggregate_function = aggregate_function
      @column_name = column_name
      @scope = scope
    end
  end
end
