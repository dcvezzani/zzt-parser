require File.dirname(__FILE__) + "/../models/zzt_base"

class ZZTObject < ZZTBase

  attr_accessor :x, :y, :x_step, :y_step, :cycle, :parameters
  attr_accessor :under_obj_status, :over_obj_status
  attr_accessor :under_obj_code, :under_obj_color, :unk_01
  attr_accessor :program_pos, :data_len, :binded_obj_status
  attr_accessor :unk_02, :data, :object_id

# Followed by objects, creatures, etc. in the following format:
# 1     X-coordinate on board
# 1     Y-coordinate on board
# 2     Current horizontal movement in steps a cycle
# 2     Current vertical movement in steps a cycle
# 2     Cycle number
# 3     Parameters
# 2     Stat # of the thing behind this thing (used for centipedes, -1 is no linkage)
# 2     Stat # of the thing in front of this thing (used for centipedes, -1 is no linkage)
# 1     Code for thing under this thing
# 1     Color for thing under this thing
# 4    *Unknown
# 2     Position in program as byte number minus 1, FFFFh = Program ended
# 2     Size for object/scroll
# 2     Stat # of the thing this thing is #binded to
# 6    *Unknown
# ?     Only if this is an object/scroll: Program/text according to size

  def initialize(parser, object_id)
    super
    self.parsers << parser
    @object_id = object_id
  end

  def self.parse(parser, object_id)
    obj = ZZTObject.new(parser, object_id)

    obj.read(:n, "x", 1)
    obj.read(:n, "y", 1)
    obj.read(:n, "x_step", 2)
    obj.read(:n, "y_step", 2)
    obj.read(:n, "cycle", 2)
    obj.read(:b, "parameters", 3)
    obj.read(:n, "under_obj_status", 2)
    obj.read(:n, "over_obj_status", 2)
    obj.read(:b, "under_obj_code", 1)
    obj.read(:b, "under_obj_color", 1)
    obj.read(:b, "unk_01", 4)
    obj.read(:n, "program_pos", 2) #don't forget to minus 1 unless FFFF
    obj.read(:n, "data_len", 2)
    obj.read(:n, "binded_obj_status", 2)
    obj.read(:b, "unk_02", 6)

    obj.read(:s, "data", obj.data_len)

    obj
  end

  def data(escape=false)
    (escape) ?  @data.gsub(/\r/, "\n") : @data
  end
end
