class CreateBigrams < ActiveRecord::Migration
  def change
    create_table :bigrams do |t|
      t.string :word1
      t.string :word2
      t.integer :count,:default => 1

      t.timestamps null: false
    end
  end
end
