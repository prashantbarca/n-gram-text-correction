class CreateTrigrams < ActiveRecord::Migration
  def change
    create_table :trigrams do |t|
      t.string :word1
      t.string :word2
      t.string :word3
      t.integer :count,:default => 1

      t.timestamps null: false
    end
  end
end
