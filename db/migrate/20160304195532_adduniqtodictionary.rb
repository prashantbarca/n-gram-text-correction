class Adduniqtodictionary < ActiveRecord::Migration
  def change
      change_column :dictionaries,:word,:string,:unique =>true
  end
end
