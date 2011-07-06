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

  def read_buffered_string(attr, len, label)
    res = parser.read_string(len, "#{label}")
    self.send("#{attr}=", res) unless attr.nil?
    res
  end

  def read_string(attr, len, label)
    res = parser.read_string(len, "#{label}", len)
    self.send("#{attr}=", res) unless attr.nil?
    res
  end

  def read_number(attr, len, label)
    res = parser.read_number(len, false, "#{label}")
    self.send("#{attr}=", res) unless attr.nil?
    res
  end

  def read_zero_based_number(attr, len, label)
    res = parser.read_number(len, true, "#{label}")
    self.send("#{attr}=", res) unless attr.nil?
    res
  end

  def read_boolean(attr, len, label)
    res = parser.read_number(len, false, "#{label}")
    res = (res != 0)
    self.send("#{attr}=", res) unless attr.nil?
    res
  end

  def read_bytes(attr, len, label)
    res = parser.read_bytes(len, "#{label}")
    self.send("#{attr}=", res) unless attr.nil?
    res
  end

end
