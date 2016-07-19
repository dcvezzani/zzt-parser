require File.dirname(__FILE__) + "/../models/zzt_base"

class ZZTGame < ZZTBase
 
  attr_accessor :game_id, :header, :boards

  def initialize(parser, *args)
    super(parser)
    @boards = []
  end

  def to_hash
    {game_id: game_id, header: header.to_hash, boards: boards.map(&:to_hash)}
  end

  def to_json
    attrs = to_hash
    JSON::dump(attrs)
  end
  
  def object_data
    out = []
    @boards.each{|board|
      out << "\n>>> [#{board.brd_id-1}]#{board.title} <<<"
      out << board.object_data
    }
    out
  end

  def self.parse(parser)
    game = ZZTGame.new(parser)

    game.read(:b, "game_id", 2)

    game.header = ZZTGameHeader.parse(parser)

    padding_buffer_len = "200".hex - parser.bytes_read
    game.read(:b, nil, padding_buffer_len, "padding")
    #p.read_hex_array(padding_buffer_len, true, "padding")

    (0...game.header.board_cnt).each{|index|
      game.boards << ZZTGameBoard.parse(parser, (index+1))
    }

    game.parsers.pop()

    game
  end
end


