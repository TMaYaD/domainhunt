class AddEndDateToDomains < ActiveRecord::Migration
  def change
    add_column :domains, :end_date, :datetime
  end
end
