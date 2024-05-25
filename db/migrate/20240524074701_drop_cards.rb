class DropCards < ActiveRecord::Migration[7.1]
  def change
    drop_table :cards
  end
end
