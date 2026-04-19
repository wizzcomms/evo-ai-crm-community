class AddAccountMultiTenancyFoundation < ActiveRecord::Migration[7.1]
  def up
    create_accounts_table
    add_account_references
    backfill_default_account
  end

  def down
    remove_account_references
    drop_table :accounts, if_exists: true
  end

  private

  def create_accounts_table
    return if table_exists?(:accounts)

    create_table :accounts, id: :uuid do |t|
      t.string :name, null: false
      t.string :subdomain, null: false
      t.boolean :default, null: false, default: false
      t.timestamps
    end

    add_index :accounts, :subdomain, unique: true
    add_index :accounts, :default
  end

  def add_account_references
    %i[contacts inboxes conversations contact_inboxes].each do |table|
      next if column_exists?(table, :account_id)

      add_reference table, :account, type: :uuid, index: true, foreign_key: true
    end
  end

  def remove_account_references
    %i[contacts inboxes conversations contact_inboxes].each do |table|
      remove_reference table, :account, type: :uuid, index: true, foreign_key: true if column_exists?(table, :account_id)
    end
  end

  def backfill_default_account
    account_id = select_value(<<~SQL.squish)
      INSERT INTO accounts (id, name, subdomain, "default", created_at, updated_at)
      VALUES (gen_random_uuid(), 'WizzDesk', 'default', true, NOW(), NOW())
      ON CONFLICT (subdomain) DO UPDATE SET updated_at = NOW()
      RETURNING id
    SQL

    %i[contacts inboxes conversations contact_inboxes].each do |table|
      next unless column_exists?(table, :account_id)

      execute <<~SQL.squish
        UPDATE #{table}
        SET account_id = '#{account_id}'
        WHERE account_id IS NULL
      SQL
    end
  end
end
