require File.dirname(__FILE__) + "/../lib/zzt_parser_utils"

class ZZTGameHeader
  include ZZTParserUtils
 
  attr_accessor :parser
  attr_accessor :board_cnt, :ammo_cnt, :gems_cnt, :keys, :health_cnt, \
    :board_start, :torches_cnt, :torch_cycle_cnt, :ener_cycle_cnt, \
    :unk_01, :score_cnt, :world_title, :flags, :timer_cnt, :unk_02, \
    :saved_game

  KEYS = %w{blue green cyan red purple yellow white}
  FLAGS_CNT = 10

  def initialize
    #hash of keys, initialized to false
    @keys = KEYS.inject({}){|a,b| a.merge(b.to_sym() => false) }
    @flags = [0..FLAGS_CNT].map{|x| nil}
  end

=begin
2     FFFFh verifies that this is a ZZT file
2     Number of boards minus 1
2     Starting ammo
2     Starting gems
7     Starting keys (Nonzero if player has it)
      Order: blue, green, cyan, red, purple, yellow, white
2     Starting health
2     Starting board
2     Starting torches
2     Number of cycles until torch goes out
2     Number of cycles player is still energized
2    *Unknown
2     Starting score
1     Length of world title
20    World title
210   Places for 10 flags that are set
      Flags in following format:
      1 byte = length of flag name
      20 bytes = flag name
      If the flag "SECRET" is set, then this is a protected file.
2     Time passed
2    *Unknown
1     If this byte is nonzero then this is a savegame
=end

  def self.parse(parser)
    header = ZZTGameHeader.new

    header.board_cnt = parser.read_hex_array(2, true, "board_cnt"){|bytes|
      res = ZZTParserUtils.hex_to_dec(bytes.join(""))
      (res+1) # add 1 because number of boards is zero-based
    }

    header.parse_attributes(parser, %w{ammo_cnt gems_cnt})

    header.parse_keys(parser)

    header.parse_attributes(parser, %w{health_cnt board_start 
      torches_cnt torch_cycle_cnt ener_cycle_cnt unk_01 score_cnt})

    header.parse_title(parser)

    header.parse_flags(parser)

    header.parse_attributes(parser, %w{timer_cnt unk_02})
    
    header.saved_game = parser.read_hex_array(1, true, "saved_game"){|bytes|
      res = ZZTParserUtils.hex_to_dec(bytes.join(""))
      (res != 0)
    }

    header
  end

# def parse_attributes(parser, attr_arr)
#   attr_arr.each{|attr|
#     self.send("#{attr}=".to_sym(), parser.read_hex_array(2){|bytes|
#       res = ZZTParserUtils.hex_to_dec(bytes.join(""))
#       res
#     })
#   }
# end

  def parse_flags(parser)
    @flags = (0...FLAGS_CNT).map{|x|
      flag = parser.read_string(20, "flag_#{x.to_s.rjust(2, '0')}")
      flag
    }
  end

  def parse_title(parser)
    @world_title = parser.read_string(20, "world_title")
  end

  def parse_keys(parser)
    @keys = KEYS.inject({}){|hash, color|
      parser.read_hex_array(1, true, "key_#{color}"){|bytes|
        res = ZZTParserUtils.hex_to_dec(bytes.join(""))
        player_has_key = (res != 0)
        hash.merge(color.to_sym() => player_has_key)
      }
    }
  end

end
