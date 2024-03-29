# frozen_string_literal: true

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.string :name
    t.timestamps null: false
  end

  create_table :posts, force: true do |t|
    t.string :title
    t.string :body
    t.integer :user_id
    t.timestamps null: false
  end

  create_table :comments, force: true do |t|
    t.string :body
    t.string :status
    t.string :author_type
    t.integer :author_id
    t.integer :rating
    t.integer :post_id
    t.timestamps null: false
  end

  create_table :teachers, force: true do |t|
    t.string :name
    t.timestamps null: false
  end

  create_table :students, force: true do |t|
    t.string :name
    t.timestamps null: false
  end

  create_table :students_teachers, force: true do |t|
    t.integer :student_id
    t.integer :teacher_id
  end

  create_table :homeworks, force: true do |t|
    t.integer :teacher_id
    t.integer :student_id
  end

  create_table :vehicles, force: true do |t|
    t.string :type
    t.string :name
    t.timestamps null: false
  end

  create_table :passengers, force: true do |t|
    t.integer :vehicle_id
    t.string :name
    t.integer :age

    t.timestamps null: false
  end
end
