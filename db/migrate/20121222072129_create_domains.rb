class CreateDomains < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.string :name
      t.decimal :min_bid, :precision => 6, :scale => 2
      t.date :release_date
      t.string :status

      t.timestamps
    end
  end
end
