Sequel.migration do
  up do
    alter_table :problems do
      add_column :solution, String
      add_column :kind, String, null: false, default: 'contest', index: true
    end
  end

  down do
    alter_table :problems do
      drop_column :solution
      drop_column :kind
    end
  end
end
