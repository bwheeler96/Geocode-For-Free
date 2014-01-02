class CreateApps < ActiveRecord::Migration
  def change
		create_table :applications do |t|
			t.string :email
			t.string :name
			t.text :description
			t.string :api_key
		end
  end
end
