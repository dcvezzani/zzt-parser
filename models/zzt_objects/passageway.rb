require File.dirname(__FILE__) + "/../../models/zzt_base"

module ZZTObjects
  class Passegeway < ZZTObject
    attr_active :x, :y, :p3

    def initialize(*args)
      super(*args)
      self.cycle = 1 if self.cycle.nil?
    end
  end
end

