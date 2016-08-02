require File.dirname(__FILE__) + "/../models/zzt_base"

class ZZTObject < ZZTBase

  attr_accessor :x, :y, :x_step, :y_step, :cycle, :p1, :p2, :p3
  attr_accessor :under_obj_status, :over_obj_status
  attr_accessor :under_obj_code, :under_obj_color, :pointer
  attr_accessor :program_pos, :data_len, :binded_obj_status
  attr_accessor :unk_02, :data, :obj_id

  def self.inherited(child)
    child.instance_eval do
      def attr_active(*args)
        @attrs_active = [] if @attrs_active.nil?
        clean_attrs = args.select{|attr| 
          [:x, :y, :x_step, :y_step, :cycle, :p1, :p2, :p3, :under_obj_status, :over_obj_status, :under_obj_code, :under_obj_color, :pointer, :program_pos, :data_len, :binded_obj_status, :unk_02, :data, :obj_id].include? attr}

        @attrs_active.concat(clean_attrs)
      end
    end

    child.class_eval do
      def to_json
        {"#{self.class.name}::#{self.object_id}" => (self.class.attrs_active.inject({}){|hash, attr|
          hash.merge!({attr => self.send(attr)})
        })}.to_json
      end

      def to_s
        attrs = self.class.attrs_active.map{|attr| "@#{attr}".to_sym}.inject([]){|a,b| a << "#{b}=#{self.instance_variable_get(b)}"}
        "\n<#{self.class}:#{self.object_id}\n\t #{attrs.join(' ')}>"
      end
          
    end

    class << child
      attr_accessor :attrs_active
    end
  end

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

  def initialize(parser, obj_id)
    super(parser)
    @obj_id = obj_id
  end

  def self.from_json(json)
    object = ZZTObject.allocate

    [:x, :y, :x_step, :y_step, :cycle, :p1, :p2, :p3, :under_obj_status, :over_obj_status, :under_obj_code, :under_obj_color, :pointer, :program_pos, :data_len, :binded_obj_status, :unk_02, :data, :obj_id].each do |attr|
      object.send("#{attr}=", json[attr.to_s])
    end

    object
  end
  
  def self.parse(parser, obj_id)
    obj = ZZTObject.new(parser, obj_id)

    obj.read(:n, "x", 1)
    obj.read(:n, "y", 1)
    obj.read(:n, "x_step", 2)
    obj.read(:n, "y_step", 2)
    obj.read(:n, "cycle", 2)
    obj.read(:n, "p1", 1)
    obj.read(:n, "p2", 1)
    obj.read(:n, "p3", 1)
    obj.read(:b, "under_obj_status", 2)
    obj.read(:b, "over_obj_status", 2)
    obj.read(:b, "under_obj_code", 1)
    obj.read(:b, "under_obj_color", 1)
    obj.read(:b, "pointer", 4)
    obj.read(:n, "program_pos", 2) #don't forget to minus 1 unless FFFF
    obj.read(:n, "data_len", 2)
    obj.read(:n, "binded_obj_status", 2)
    obj.read(:b, "unk_02", 6)

    obj.read(:s, "data", obj.data_len)

    obj.parsers.pop()

    obj
  end

  def to_bytes(parser)
    self.parsers = [] if self.parsers.nil?
    self.parsers << parser

    self.write(:n, "x", 1)
    self.write(:n, "y", 1)
    self.write(:n, "x_step", 2)
    self.write(:n, "y_step", 2)
    self.write(:n, "cycle", 2)
    self.write(:n, "p1", 1)
    self.write(:n, "p2", 1)
    self.write(:n, "p3", 1)
    self.write(:b, "under_obj_status", 2)
    self.write(:b, "over_obj_status", 2)
    self.write(:b, "under_obj_code", 1)
    self.write(:b, "under_obj_color", 1)
    self.write(:b, "pointer", 4)
    self.write(:n, "program_pos", 2) #don't forget to minus 1 unless FFFF

    self.data_len = ((self.data and self.data.length) or 0)
    self.write(:n, "data_len", 2)
    self.write(:n, "binded_obj_status", 2)
    self.write(:b, "unk_02", 6)

    self.write(:s, "data", self.data_len)

    self.parsers.pop
    parser.hex_array
  end

  def data(escape=false)
    (escape) ?  @data.gsub(/\r/, "\n") : @data
  end
end




