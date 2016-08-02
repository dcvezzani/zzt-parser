require "rubygems"
require "bundler/setup"

require File.dirname(__FILE__) + "/models/zzt_game_header"
require File.dirname(__FILE__) + "/lib/zzt_parser_utils"

# require your gems as usual
require "ruby-debug"


class ZZTParser
  include ZZTParserUtils
  attr_accessor :game_file, :hex_array, :game_header, :game_boards
  attr_reader :original_hex_array

  alias_method :ha, :hex_array

  def initialize(arg, options={})
    @game_header = nil
    @content = nil
    @game_boards = []
    #@offset_position = (options[:offset] or 0)

    if(arg.is_a?(Array))
      @original_hex_array = arg
    else
      @game_file = arg
      load_file
    end

    reset
    self
  end

  def write_bytes_raw(bytes, label)
    self.write_bytes(bytes, bytes.length, "#{label}")
  end

  def bytes_read(options={offset: 0})
    res = self.original_hex_array.slice(0, self.original_hex_array.length - self.hex_array.length)    
    res = res.slice(options[:offset], res.length) if options[:offset] > 0
    res
  end

  def bytes_written
    self.hex_array
  end

  alias_method :br, :bytes_read
  alias_method :bw, :bytes_written

  def bytes_original_len
    @original_hex_array.length
  end

  def load_file
    File.open(game_file,"rb") do |f|  
     buffer = nil
     while((buffer = f.read(2048)))
       (@content ||= '') << buffer
     end
    end

    # now parse @header to hex array  
    @original_hex_array = @content.each_byte.collect {|val| "%02X" % val}  
  end

  def save_file(game_file="#{@game_file}.NEW")
    File.open(game_file,"wb") do |f|  
      f.write(@hex_array.map { |x| x.hex.chr }.join)
    end
  end

  def reset
    @hex_array = @original_hex_array.clone()
  end

  def self.parse(filename = "../tour.zzt")
    p = ZZTParser.new(filename)

    game = ZZTGame.parse(p)
    File.open("object-data.txt", "w"){|f| f.write(game.object_data.join("\n"))}
    game
  end
end





