class ActiveRecord::Relation
  # Post.all.eager_group(:approved_comments_count, :comments_average_rating)

  def exec_queries_with_eager_group
    records = exec_queries_without_eager_group
    if eager_group_values.present?
      EagerGroup::Preloader.new(self.klass, records, eager_group_values).run
    end
    records
  end
  alias_method_chain :exec_queries, :eager_group

  def eager_group(*args)
    check_if_method_has_arguments!('eager_group', args)
    spawn.eager_group!(*args)
  end

  def eager_group!(*args)
    self.eager_group_values += args
    self
  end

  def eager_group_values
    @values[:eager_group] || []
  end

  def eager_group_values=(values)
    raise ImmutableRelation if @loaded

    @values[:eager_group] = values
  end
end
