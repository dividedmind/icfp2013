class Status < Sequel::Model(:status)
  def self.as_json *a
    first.as_json *a
  end
  
  def self.fresh
    db.transaction do
      record = first
      if record.request_window_resets_at < Time.now || record.cpu_window_resets_at < Time.now
        update Oracle.status
      end
      first
    end
  end
  
  def self.update data
    record = first || new
    (%w(easyChairId contestScore lightningScore trainingScore mismatches numRequests cpuTotalTime) & data.keys).each do |k|
      record.set k.underscore => data[k]
    end
    if rwin = data["requestWindow"]
      amt = record.request_window_amount = rwin["amount"] if rwin["amount"]
      record.request_window_limit = rwin["limit"] if rwin["limit"]
      record.request_window_resets_at = Time.now + rwin["resetsIn"].seconds
      if amt == 1
        record.window_length = rwin["resetsIn"].ceil.to_s + " seconds"
      end
    end
    if rwin = data["cpuWindow"]
      amt = record.cpu_window_amount = rwin["amount"] if rwin["amount"]
      record.cpu_window_limit = rwin["limit"] if rwin["limit"]
      record.cpu_window_resets_at = Time.now + rwin["resetsIn"].seconds
    end
    
    record.save
  end
  
  def as_json *_
    result = Hash[super.map {|k, v| [k.to_s.camelize(:lower), v]}]
    result.delete_if {|k| k =~ /Window/}

    result[:requestWindow] = {
      resetsIn: [request_window_resets_at - Time.now, 0].max,
      limit: request_window_limit,
      amount: request_window_amount
    }
    result[:cpuWindow] = {
      resetsIn: [cpu_window_resets_at - Time.now, 0].max,
      limit: cpu_window_limit,
      amount: cpu_window_amount
    }
    
    return result
  end
  
  def save
    self.class.dataset.update values
    self.class.first
  end
end
