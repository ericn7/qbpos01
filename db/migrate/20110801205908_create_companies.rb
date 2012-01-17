class CreateCompanies < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.string :name
      t.string :realm
      t.references :owner
      t.string :intuit_access_token
      t.string :intuit_access_secret
      t.boolean :is_qbo
      t.timestamps
    end
    create_table :companies_users, :id => false do |t|
      t.references :user
      t.references :company
    end
  end

  def self.down
    drop_table :companies
    drop_table :companies_users
  end
end
