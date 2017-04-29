require "time"

class Time
  def to_json(ignore = nil)
    %Q["#{self.iso8601(3)}"]
  end
end
