Sequel.migration do
  change do
    create_table(:problems) do
      column :id, "text", :null=>false
      column :size, "integer", :null=>false
      column :operators, "text[]", :null=>false
      column :solved, "boolean", :default=>false, :null=>false
      column :expires_at, "timestamp without time zone"
      
      primary_key [:id]
    end
    
    create_table(:schema_migrations) do
      column :filename, "text", :null=>false
      
      primary_key [:filename]
    end
    
    create_table(:status) do
      column :easy_chair_id, "integer"
      column :contest_score, "integer"
      column :lightning_score, "integer"
      column :training_score, "integer"
      column :mismatches, "integer"
      column :num_requests, "integer"
      column :request_window_resets_at, "timestamp without time zone"
      column :request_window_amount, "integer"
      column :request_window_limit, "integer"
      column :cpu_window_resets_at, "timestamp without time zone"
      column :cpu_window_amount, "integer"
      column :cpu_window_limit, "integer"
      column :cpu_total_time, "numeric"
      column :window_length, "numeric"
    end
  end
end
