require File.dirname(__FILE__) + "/../../models/zzt_base"

module ZZTObjects
  class Scroll < ZZTObject
    attr_active :x, :y, :cycle, :cur_ins, :data_len, :data

    def initialize(*args)
      super(*args)
      self.cycle = 1 if self.cycle.nil?
    end
  end
end

