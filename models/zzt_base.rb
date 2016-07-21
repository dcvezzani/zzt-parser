require File.dirname(__FILE__) + "/../lib/zzt_parser_utils"

class ZZTBase
  include ZZTParserUtils

  attr_accessor :parsers, :origdata, :bounds

  alias_method :sp, :bounds

  def initialize(*args)
    @parsers = []
    @parsers << args.first
    @origdata = (args.first).instance_variable_get(:@original_hex_array).clone
    #@_start_pos = @parsers.inject(0){|total,p| total = total + p.next_position}
    #@_start_pos = args.first.net_next_position.last
    @bounds = {:start => args.first.net_next_position}
  end

  def done
    bounds[:stop] = parser.net_next_position.map{|el| el-=1}
  end

  def hex_code_values
    origdata[(bounds[:start].first)..(bounds[:stop].first)]
  end

  def parser
    (@parsers and @parsers.last)
  end

  def parser=(parser)
    @parsers << parser
  end

  def parser_next_position
    parser.net_next_position.last
  end

# alias_method :orig_inspect, :inspect
# def inspect
#   orig_inspect
# end

  def to_hash
    attrs = (self.instance_variables - [:@parsers, :@origdata, :@bounds]).inject({}){|a,b| a.merge!({b.to_s.slice(1,b.to_s.length) => self.instance_variable_get(b)})}
  end

  def to_s
    attrs = (self.instance_variables - [:@parsers, :@origdata, :@bounds]).inject([]){|a,b| a << "#{b}=#{self.instance_variable_get(b)}"}

    "\n<#{self.class}:#{self.object_id}\n\t #{attrs.join(' ')}>"
    #"<#{self.class}:#{self.object_id} #{(self.instance_variables - [:@parsers])}>"
  end
  
  def dump_yaml
    tmp = self.clone()
    [:parsers].each{|x| tmp.send("#{x}=", nil)}
    #Psych.dump(tmp)
    tmp.to_yaml
  end

  def read(type, attr, len, label=nil)
    label ||= attr.to_s
    res = case(type)
    when :string, :s  then read_string(attr, len, label)
    when :buffered_string, :bs  then read_buffered_string(attr, len, label)
    when :number, :n  then read_number(attr, len, label)
    when :zero_based_number, :n0  then read_zero_based_number(attr, len, label)
    when :bytes,  :b  then read_bytes(attr, len, label)
    when :boolean,  :tf  then read_boolean(attr, len, label)
    end

    #self.send(attr)
    res
  end

  def write(type, attr, len, label=nil)
    label ||= attr.to_s
    res = case(type)
    when :string, :s  then write_string(attr, len, label)
    when :buffered_string, :bs  then write_buffered_string(attr, len, label)
    when :number, :n  then write_number(attr, len, label)
    when :zero_based_number, :n0  then write_zero_based_number(attr, len, label)
    when :bytes,  :b  then write_bytes(attr, len, label)
    when :boolean,  :tf  then write_boolean(attr, len, label)
    end

    #self.send(attr)
    res
  end

  def ignore(attr, label)
    attr.nil? # or label.match(/^unk_/)
  end

  def write_buffered_string(attr, len, label)
    str = self.send("#{attr}")

    res = parser.write_number(str.length, len, "#{label}")
    res = parser.write_string(str, len, "#{label}")
    res
  end

  def write_string(attr, len, label)
    str = self.send("#{attr}")

    res = parser.write_string(str, len, "#{label}")
    res
  end

  def write_number(attr, len, label, options={zero_based: false})
    num = self.send("#{attr}")

    res = parser.write_number(num, len, "#{label}", options)
    res
  end

  def write_zero_based_number(attr, len, label, options={zero_based: true})
    num = self.send("#{attr}")

    res = parser.write_number(num, len, "#{label}", options)
    res
  end

  def write_boolean(attr, len, label)
    tf = self.send("#{attr}")
    num = (tf == true) ? 1 : 0
    res = parser.write_number(num, len, "#{label}")
    res
  end

  def write_bytes(attr, len, label)
    bytes = self.send("#{attr}")

    res = parser.write_bytes(bytes, len, "#{label}")
    res
  end

  def read_buffered_string(attr, len, label)
    res = parser.read_string(len, "#{label}")
    self.send("#{attr}=", res) unless ignore(attr, label)
    res
  end

  def read_string(attr, len, label)
    res = parser.read_string(len, "#{label}", len)
    self.send("#{attr}=", res) unless ignore(attr, label)
    res
  end

  def read_number(attr, len, label)
    res = parser.read_number(len, false, "#{label}")
    self.send("#{attr}=", res) unless ignore(attr, label)
    res
  end

  def read_zero_based_number(attr, len, label)
    res = parser.read_number(len, true, "#{label}")
    self.send("#{attr}=", res) unless ignore(attr, label)
    res
  end

  def read_boolean(attr, len, label)
    res = parser.read_number(len, false, "#{label}")
    res = (res != 0)
    self.send("#{attr}=", res) unless ignore(attr, label)
    res
  end

  def read_bytes(attr, len, label)
    res = parser.read_bytes(len, "#{label}")
    self.send("#{attr}=", res) unless ignore(attr, label)
    res
  end

end
