require File.dirname(__FILE__) + "/../../models/zzt_base"

module ZZTObjects
  class Player < ZZTObject
    attr_active :x, :y, :cycle

    def initialize(*args)
      super(*args)
      self.cycle = 1 if self.cycle.nil?
    end
  end
end

