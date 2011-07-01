require File.dirname(__FILE__) + "/../lib/zzt_parser_utils"

class ZZTGameBoard
  include ZZTParserUtils

  attr_accessor :board_size, :title, :unk_01, :raw, :tiles
  attr_accessor :board_id
  TILE_CNT = 1500 #(60*25)

  attr_accessor :shots_fired_max, :darkness, :boards
  attr_accessor :re_enter_when_zapped
  attr_accessor :on_screen_message, :unk_02, :time_limit
  attr_accessor :unk_03, :object_cnt
  attr_accessor :player_x, :player_y
  attr_accessor :objects

  def initialize(board_id)
    @board_id = board_id
    @boards = {
      :north => nil, 
      :south => nil, 
      :west  => nil, 
      :east  => nil
    }

    @tiles = []
    @objects = []
  end


# 2     Board size (excluding these 2 bytes)
# 1     Length of board title
# 34    Board title
# 16   *Unknown
debugger
  def self.parse(parser, board_id)
    board = ZZTGameBoard.new(board_id)

    #board.board_size = parser.read_number(2, false, "board_size")

    board.board_size = parser.read_hex_array(2, true, "board_size"){|bytes|
      res = ZZTParserUtils.hex_to_dec(bytes.join(""))
      (res - 51)
    }

    board.title = parser.read_string(34, "board_title")
    board.unk_01 = parser.read_bytes(16, "board_unk_01")

    board.raw = parser.read_bytes(board.board_size, "raw_board_bytes")

    board_parser = ZZTParser.new(board.raw)

    tile_cnt = 0
    while(tile_cnt < 1500)
      raw_tile = board_parser.read_bytes(3, "raw_tile")
      tile = ZZTBoardTile.parse(ZZTParser.new(raw_tile))
      tile_cnt += tile.cnt
    end

#  Label   | Location | Description
# ---------+----------+------------------------------------------
#  m#s     | 00       | Maximum number of shots fired
#  drk     | 01       | Darkness: 0=no, 1=yes
#  Bn      | 02       | Board # to north: 0=none, 1=second board
#  Bs      | 03       | Board # to south: 0=none, 1=second board
#  Bw      | 04       | Board # to west: 0=none, 1=second board
#  Be      | 05       | Board # to east: 0=none, 1=second board
#  Re      | 06       | Re-enter when zapped: 0=no, 1=yes
#  lM      | 07       | Length of on-screen message
#  Message | 08-41    | On-screen message (internal use only)
#  00 00   | 42-43    | Padding?
#  T.Limit | 44-45    | Time Limit for board
#  Padding | 46-55    | Fill with zeros
#  # obj   | 56-57    | Number of objects on board

# attr_accessor :shots_fired_max, :darkness, :boards
# attr_accessor :re_enter_when_zapped
# attr_accessor :on_screen_message, :unk_02, :time_limit
# attr_accessor :unk_03, :object_cnt

    board.shots_fired_max = board_parser.read_number(1, false, "max_shots_fired")

    board.darkness = board_parser.read_hex_array(1, false, "darkness"){|bytes|
      res = ZZTParserUtils.hex_to_dec(bytes.join(""))
      (res == 1)
    }

    [:north, :south, :west, :east].each{|dir|
      board.boards[dir] = board_parser.read_number(1, false, "board_dir_#{dir}") 
    }

    board.re_enter_when_zapped = board_parser.read_number(1, false, "re_enter_when_zapped")

    board.on_screen_message = board_parser.read_string(58, "on_screen_message")

    board.player_x = board_parser.read_number(1, false, "player_x")
    board.player_y = board_parser.read_number(1, false, "player_y")

    board.time_limit = board_parser.read_number(2, false, "time_limit")

    board.unk_02 = board_parser.read_bytes(16, "unk_02")

    board.object_cnt = board_parser.read_hex_array(2, true, "object_cnt"){|bytes|
      res = ZZTParserUtils.hex_to_dec(bytes.join(""))
      #(res-1) #number of things with parameters
      (res+1) #number of things with parameters
    }

    (0...board.object_cnt).each{|index|
      board.objects << ZZTObject.parse(board_parser, (index+1))
    }
    #board.parse_attributes(parser, %w{ammo_cnt gems_cnt})
    board
  end

end
