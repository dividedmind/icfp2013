Sequel.migration do
  up do
    create_table :problems do
      String :id, null: false, primary_key: true
      Fixnum :size, null: false, index: true
      send :"text[]", :operators, null: false
      Boolean :solved, null: false, default: false
      Time :expires_at
    end
  end

  down do
    drop_table :problems
  end
end
