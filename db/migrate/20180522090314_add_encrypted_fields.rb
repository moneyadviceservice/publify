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
    add_column :feedback, :encrypted_author, :string
    add_column :feedback, :encrypted_author_iv, :string
    add_column :feedback, :encrypted_email, :string
    add_column :feedback, :encrypted_email_iv, :string
    add_column :feedback, :encrypted_ip, :string
    add_column :feedback, :encrypted_ip_iv, :string
    # blind index
    add_index :users, :encrypted_login_bidx, unique: true
    add_index :users, :encrypted_email_bidx, unique: true
    # rename old columns
    rename_column :users, :email, :email_old
    rename_column :users, :login, :login_old
    rename_column :users, :name, :name_old
    rename_column :feedback, :author, :author_old
    rename_column :feedback, :email, :email_old
    rename_column :feedback, :ip, :ip_old

    User.reset_column_information
    User.find_each do |instance|
      #this will set the encrypted_reply based on attr_encrypted
      instance.email = instance.email_old
      instance.login = instance.login_old
      instance.name = instance.name_old
      instance.save!
    end

    Feedback.reset_column_information
    Feedback.find_each do |instance|
      #this will set the encrypted_reply based on attr_encrypted
      instance.author = instance.author_old
      instance.email = instance.email_old
      instance.ip = instance.ip_old
      instance.save!
    end
  end

  def down
    rename_column :users, :email_old, :email
    rename_column :users, :login_old, :login
    rename_column :users, :name_old, :name
    rename_column :feedback, :author_old, :author
    rename_column :feedback, :email_old, :email
    rename_column :feedback, :ip_old, :ip
  end
end
