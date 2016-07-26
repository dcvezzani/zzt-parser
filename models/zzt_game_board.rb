require File.dirname(__FILE__) + "/../models/zzt_base"


class ZZTGameBoard < ZZTBase

  module ZZTTileExt
    def to_s
      "#{color} #{code}"
    end
  end

  attr_accessor :board_size, :title, :unk_01, :tiles
  attr_accessor :brd_id
  TILE_CNT = 1500 #(60*25)

  attr_accessor :shots_fired_max, :darkness, :boards
  attr_accessor :re_enter_when_zapped
  attr_accessor :on_screen_message, :unk_02, :time_limit
  attr_accessor :unk_03, :object_cnt
  attr_accessor :player_x, :player_y
  attr_accessor :objects

  def initialize(parser, board_id)
    super(parser)
    @brd_id = board_id
    @boards = {
      :north => nil, 
      :south => nil, 
      :west  => nil, 
      :east  => nil
    }

    @tiles = []
    @objects = []
  end

  def self.from_json(json)
    board = ZZTGameBoard.allocate

    [:board_size, :boards, :title, :unk_01, :brd_id, :shots_fired_max, :darkness, :re_enter_when_zapped, :on_screen_message, :unk_02, :time_limit, :unk_03, :object_cnt, :player_x, :player_y].each do |attr|
      board.send("#{attr}=", json[attr.to_s])
    end

    board.objects = json['objects'].map do |obj|
      ZZTObject.from_json(obj)
    end

    board.tiles = json['tiles'].map do |tile|
      ZZTBoardTile.from_json(tile)
    end
    
    board
  end
  
  def to_hash
    attrs = (self.instance_variables - [:@parsers, :@tiles, :@objects, :@origdata, :@bounds]).inject({}){|a,b| a.merge!({b.to_s.slice(1,b.to_s.length) => self.instance_variable_get(b)})}
    {tiles: tiles.map(&:to_hash), objects: objects.map(&:to_hash)}.merge(attrs)
  end

  def read_board_size
    @board_size = parser.read_hex_array(2, true, "board_size"){|bytes|
      res = ZZTParserUtils.hex_to_dec(bytes.join(""))
      (res - 51)
    }
  end

  def tile_at(x,y)
    tile_cnt_target = (((y-1)*60) + (x-1))
    tile_cnt = 0
    tile = nil
    for i in 0...@tiles.length; tile = @tiles[i]
      break unless(tile_cnt < tile_cnt_target and tile_cnt < 1500)
      tile_cnt += tile.cnt
    end

    tile
  end

  def item_at(x,y)
    tile = tile_at(x,y)
    res = (tile) ? tile.extend(ZZTTileExt).to_s : "???"
    res
  end

  def objects_with_data
    @objects.select{|x| x.data != nil and x.data.length > 0}.sort{|a,b| "#{a.x.to_s.rjust(2,"0")}#{a.y.to_s.rjust(2,"0")}" <=> "#{b.x.to_s.rjust(2,"0")}#{b.y.to_s.rjust(2,"0")}"}
  end

  def object_data
    objects_with_data.map{|x| "==(#{x.obj_id.to_s.rjust(2, "0")}; pos(#{x.x.to_s.rjust(2,"0")}, #{x.y.to_s.rjust(2,"0")}))======================:
{#{item_at(x.x, x.y)}}
#{x.data(true)}
=========================================
"}
  end

  def self.parse(parser, board_id)
    board = ZZTGameBoard.new(parser, board_id)

    board.read_board_size

    board.read(:bs, "title", 34, "board_title")
    board.read(:b, "unk_01", 16, "board_unk_01")

    # raw_board_bytes_offset = board.parser_next_position
    raw = board.read(:b, nil, board.board_size, "raw_board_bytes")

    board.parsers <<  ZZTParser.new(raw)

    tile_cnt = 0
    tile_parser = nil
    board.abs_position(:r)
    while(tile_cnt < 1500)
      raw_tile = board.read(:b, nil, 3, "raw_tile")
      tile_parser = ZZTParser.new(raw_tile)
      tile = ZZTBoardTile.parse(tile_parser)
      board.tiles << tile
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

    offset = board.parser.br.length
    (0...board.object_cnt).each{|index|
      board.objects << ZZTObject.parse(board.parser, (index+1))
      board.parser.br(offset: offset)
    }

    board.parsers.pop()
    board
  end

  def title_length
    self.title.length
  end

  def blank_place_holder
    ['00']
  end

  def board_north; self.boards['north']; end
  def board_south; self.boards['south']; end
  def board_west; self.boards['west']; end
  def board_east; self.boards['east']; end

  def to_bytes(parser)
    self.parsers = [] if self.parsers.nil?
    self.parsers << parser

    #self.write(:n, "board_size_blank", 2, "board_size_placeholder")
    self.write(:n, "title_length", 1)
    self.write(:s, "title", 34)
    self.write(:b, "unk_01", 16, "unk_01_padding")

    # get tiles
    tile_parser = ZZTParser.new([])
    self.tiles.each do |tile|
      tile.to_bytes(tile_parser)
      #debugger if tile_parser.hex_array.include?(nil)
    end
    parser.write_bytes_raw(tile_parser.hex_array, "tiles")

    self.write(:n, "shots_fired_max", 1)
    self.write(:tf, "darkness", 1)
    
    [:north, :south, :west, :east].each{|dir|
      self.write(:n, "board_#{dir}", 1, "board_dir_#{dir}") 
    }
    
    self.write(:n, "re_enter_when_zapped", 1)
    self.write(:bs, "on_screen_message", 58)
    self.write(:n, "player_x", 1)
    self.write(:n, "player_y", 1)
    self.write(:n, "time_limit", 2)
    self.write(:n, "unk_02", 16)

    self.object_cnt = self.objects.length
    self.write(:n0, "object_cnt", 2)
    
    # get objects
    obj_parser = ZZTParser.new([])
    self.objects.each do |obj|
      obj.to_bytes(obj_parser)
    end
    parser.write_bytes_raw(obj_parser.hex_array, "objects")

    board_size = self.parser.hex_array.length
    #board_size = self.parser.hex_array.slice(parser.offset_position, self.parser.hex_array.length).length
    board_size_bytes = ZZTParserUtils.dec_to_hex(board_size, 2)
    board_size_bytes.map{|byte| parser.hex_array.unshift(byte)}

    #parser.offset_position = parser.hex_array.length

    self.parsers.pop
    parser.hex_array
  end

end

=begin

  attr_accessor :board_size, :title, :unk_01, :tiles
  attr_accessor :brd_id
  TILE_CNT = 1500 #(60*25)

  attr_accessor :shots_fired_max, :darkness, :boards
  attr_accessor :re_enter_when_zapped
  attr_accessor :on_screen_message, :unk_02, :time_limit
  attr_accessor :unk_03, :object_cnt
  attr_accessor :player_x, :player_y
  attr_accessor :objects

=end
