class Cities < ActiveRecord::Migration
  def change
		create_table "cities", force: true do |t|
    	t.float    "latitude"
    	t.float    "longitude"
    	t.string   "name"
    	t.string   "county"
    	t.string   "state"
    	t.string   "country"
    	t.datetime "created_at"
    	t.datetime "updated_at"
  	end		
  end
end
