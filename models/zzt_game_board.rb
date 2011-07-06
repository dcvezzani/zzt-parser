require File.dirname(__FILE__) + "/../models/zzt_base"

class ZZTGameBoard < ZZTBase

  attr_accessor :board_size, :title, :unk_01, :raw, :tiles
  attr_accessor :board_id
  TILE_CNT = 1500 #(60*25)

  attr_accessor :shots_fired_max, :darkness, :boards
  attr_accessor :re_enter_when_zapped
  attr_accessor :on_screen_message, :unk_02, :time_limit
  attr_accessor :unk_03, :object_cnt
  attr_accessor :player_x, :player_y
  attr_accessor :objects

  def initialize(parser, board_id)
    super
    self.parsers << parser
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

  def read_board_size
    @board_size = parser.read_hex_array(2, true, "board_size"){|bytes|
      res = ZZTParserUtils.hex_to_dec(bytes.join(""))
      (res - 51)
    }
  end

  def self.parse(parser, board_id)
    board = ZZTGameBoard.new(parser, board_id)

    board.read_board_size

    board.read(:bs, "title", 34, "board_title")
    board.read(:b, "unk_01", 16, "board_unk_01")
    board.read(:b, "raw", board.board_size, "raw_board_bytes")

    board.parsers <<  ZZTParser.new(board.raw)

    tile_cnt = 0
    while(tile_cnt < 1500)
      raw_tile = board.read(:b, nil, 3, "raw_tile")
      tile = ZZTBoardTile.parse(ZZTParser.new(raw_tile))
      tile_cnt += tile.cnt
    end

    board.read(:n, "shots_fired_max", 1)
    board.read(:tf, "darkness", 1)

    [:north, :south, :west, :east].each{|dir|
      board.boards[dir] = board.read(:n, nil, 1, "board_dir_#{dir}") 
    }

    board.read(:n, "re_enter_when_zapped", 1)
    board.read(:bs, "on_screen_message", 58)
    board.read(:n, "player_x", 1)
    board.read(:n, "player_y", 1)
    board.read(:n, "time_limit", 2)
    board.read(:n, "unk_02", 16)
    board.read(:n0, "object_cnt", 2)

    board_parser = board.parsers.pop()
    (0...board.object_cnt).each{|index|
      board.objects << ZZTObject.parse(board_parser, (index+1))
    }

    board
  end

end
