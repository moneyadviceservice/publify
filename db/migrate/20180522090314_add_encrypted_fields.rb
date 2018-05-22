class AddEncryptedFields < ActiveRecord::Migration
  def up
    add_column :users, :encrypted_login, :string
    add_column :users, :encrypted_login_iv, :string
    add_column :users, :encrypted_login_bidx, :string
    add_column :users, :encrypted_name, :string
    add_column :users, :encrypted_name_iv, :string
    add_column :users, :encrypted_email, :string
    add_column :users, :encrypted_email_iv, :string
    add_column :users, :encrypted_email_bidx, :string
    # blind index
    add_index :users, :encrypted_login_bidx, unique: true
    add_index :users, :encrypted_email_bidx, unique: true
    # rename old columns
    rename_column :users, :email, :email_old
    rename_column :users, :login, :login_old
    rename_column :users, :name, :name_old

    User.reset_column_information
    User.find_each do |instance|
      #this will set the encrypted_reply based on attr_encrypted
      User.email = user.email_old
      User.login = user.login_old
      User.name = user.name_old
      User.save!
    end
  end

  def down
    rename_column :users, :email_old, :email
    rename_column :users, :login_old, :login
    rename_column :users, :name_old, :name
  end
end
