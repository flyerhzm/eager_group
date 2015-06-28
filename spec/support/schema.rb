ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :posts, :force => true do |t|
    t.string :title
    t.string :body
    t.timestamps null: false
  end

  create_table :comments, :force => true do |t|
    t.string :body
    t.string :status
    t.integer :rating
    t.integer :post_id
    t.timestamps null: false
  end
end
