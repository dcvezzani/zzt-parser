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

  def self.from_json(json)
    game = ZZTGame.allocate
    game.game_id = json['game_id']
    game.header = ZZTGameHeader.from_json(json['header'])
    game.boards = json['boards'].map do |board|
      ZZTGameBoard.from_json(board)
    end
    game
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

    padding_buffer_len = "200".hex - parser.bytes_read.length
    game.read(:b, nil, padding_buffer_len, "padding")
    #p.read_hex_array(padding_buffer_len, true, "padding")

    (0...game.header.board_cnt).each{|index|
      game.boards << ZZTGameBoard.parse(parser, (index+1))
    }

    game.parsers.pop()

    game
  end

  def to_bytes(parser)
    self.parsers = [] if self.parsers.nil?
    self.parsers << parser


    self.write(:b, "game_id", 2)

    game_header_parser = ZZTParser.new([])
    self.header.to_bytes(game_header_parser)
    parser.write_bytes_raw(game_header_parser.hex_array, "game_header")
    
    padding_buffer_len = "200".hex - parser.hex_array.length
    self.write(:b, nil, padding_buffer_len, "padding"){ ['00'] }

    self.boards.each do |brd|
      brd_hex_array = brd.to_bytes(ZZTParser.new([]))
      parser.write_bytes_raw(brd_hex_array, "boards")
    end
    
    self.parsers.pop
    parser.hex_array
  end
  
end


