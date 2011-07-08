require "rubygems"
require "bundler/setup"

require File.dirname(__FILE__) + "/models/zzt_game_header"
require File.dirname(__FILE__) + "/lib/zzt_parser_utils"

# require your gems as usual
require "ruby-debug"


class ZZTParser
  include ZZTParserUtils
  attr_accessor :game_file, :hex_array, :game_header, :game_boards

  def initialize(arg)
    @game_header = nil
    @content = nil
    @game_boards = []

    if(arg.is_a?(Array))
      @original_hex_array = arg
    else
      @game_file = arg
      load_file
    end

    reset
    self
  end

  def bytes_read
    (@original_hex_array.length - @hex_array.length)
  end

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

