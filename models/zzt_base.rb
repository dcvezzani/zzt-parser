require File.dirname(__FILE__) + "/../lib/zzt_parser_utils"

class ZZTBase
  include ZZTParserUtils

  attr_accessor :parsers

  def initialize(*args)
    @parsers = []
    @parsers << args.first
  end

  def parser
    (@parsers and @parsers.last)
  end

  def parser=(parser)
    @parsers << parser
  end

# alias_method :orig_inspect, :inspect
# def inspect
#   orig_inspect
# end

  def to_s
    attrs = (self.instance_variables - [:@parsers]).inject([]){|a,b| a << "#{b}=#{self.instance_variable_get(b)}"}

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

  def ignore(attr, label)
    attr.nil? # or label.match(/^unk_/)
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
