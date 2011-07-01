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

  def self.parse
    p = ZZTParser.new("/Users/davidvezzani/projects/zzt/zzt/tour.zzt")

    zzt_game_identifier = p.read_hex_array(2, true, "zzt_file")

    game_header = p.game_header = ZZTGameHeader.parse(p)

#   p.game_boards = (0...p.game_header.board_cnt).map{|x|
#     ZZTGameBoard.parse(p)
#   }

    padding_buffer_len = "200".hex - p.bytes_read
    p.read_hex_array(padding_buffer_len, true, "padding")
    #(0...padding_buffer_len).each{|x| p.hex_array.shift()}
    #p.hex_array.slice!(padding_buffer_len, p.bytes_original_len)

    (0...game_header.board_cnt).each{|index|
      p.game_boards << ZZTGameBoard.parse(p, (index+1))
    }

    p
  end
end

