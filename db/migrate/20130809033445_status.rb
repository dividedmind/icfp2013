Sequel.migration do
  up do
    create_table :status do
      Fixnum :easy_chair_id
      Fixnum :contest_score
      Fixnum :lightning_score
      Fixnum :training_score
      Fixnum :mismatches
      Fixnum :num_requests
      DateTime :request_window_resets_at
      Fixnum :request_window_amount
      Fixnum :request_window_limit
      DateTime :cpu_window_resets_at
      Fixnum :cpu_window_amount
      Fixnum :cpu_window_limit
      Numeric :cpu_total_time
      interval :window_length
    end
  end

  down do
    drop_table :status
  end
end
