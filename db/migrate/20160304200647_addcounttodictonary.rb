class Addcounttodictonary < ActiveRecord::Migration
  def change
      add_column :dictionaries  , :count , :integer, :default => 1
  end
end
