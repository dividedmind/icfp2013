class Status < Sequel::Model(:status)
  def self.as_json *a
    first.as_json *a
  end
  
  def self.fresh
    db.transaction do
      record = first
      if !record || record.request_window_resets_at < Time.now || record.cpu_window_resets_at < Time.now
        update Oracle.status
      end
      first
    end
  end
  
  def self.any
    first || fresh
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
        record.window_length = rwin["resetsIn"].ceil
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
    return super if new?
    self.class.dataset.update values
    self.class.first
  end
  
  def left_to_reset
    request_window_resets_at - Time.now
  end
  
  def wait_time
    interv = left_to_reset
    if interv > 0
      if requests_left > 0
        return interv / requests_left / 2
      else
        return interv
      end
    else
      0
    end
  end
  
  def requests_left
    request_window_limit - request_window_amount
  end
  
  def window_length
    20
  end
  
  def sent_request!
    if left_to_reset <= 0
      self.request_window_amount = 0
      self.request_window_resets_at = Time.now + window_length.seconds
    end
    self.request_window_amount += 1
    save
  end
  
  def self.throttle! &block
    db.transaction do
      if 
        status = first
        wt = status.wait_time
        Rails.logger.info "Sleeping #{wt}"
        sleep wt
        result = yield
        status.sent_request!
        result
      else
        yield
      end
    end
  end
end
