class AddConfirmationToApps < ActiveRecord::Migration
  def up
    add_column :applications, :confirmation, :string
    add_column :applications, :confirmed_at, :timestamp
  end

  def down
  end
end
