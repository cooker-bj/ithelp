class CreateItCases < ActiveRecord::Migration
  def change
    create_table :it_cases do |t|
      t.integer :user_id
      t.string :name
      t.string :department
      t.text :description
      t.datetime :create_time
      t.string :email
      t.string :phone
      t.string :location

      t.timestamps
    end
  end
end
