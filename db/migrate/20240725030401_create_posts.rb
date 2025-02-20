class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :content
      t.integer :status, default: 0
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :posts, [:user_id, :created_at]
  end
end
