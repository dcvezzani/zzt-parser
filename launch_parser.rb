def zzt_reload(filename)
  [:Code].each{|x|
    begin
      ZZTObject.send(:remove_const, x)
    rescue
    end
  }
  [:ZZTGame, :ZZTBase, :ZZTObject, :ZZTBoardTile, :ZZTGameBoard, :ZZTGameHeader, :ZZTParser, :ZZTParserUtils].each{|x| 
    begin
      Object.send(:remove_const, x)
    rescue
    end
  }
  require 'ruby-debug'
  require 'json'
  load './lib/zzt_parser_utils.rb'
  load './models/zzt_base.rb'
  load './models/zzt_game.rb'
  load './zzt_parser.rb'
  load './models/zzt_game_header.rb'
  load './models/zzt_board_tile.rb'
  load './models/zzt_game_board.rb'
  load './models/zzt_object.rb'

debugger
  game = ZZTParser.parse(filename)
  # game.to_json
  # puts game.header.inspect
  # puts game.boards.first.inspect
  game
end

#game = zzt_reload("../townb.zzt"); nil
game = zzt_reload("/Users/davidvezzani/DOS\ Games/Zzt.boxer/C.harddisk/zzt/MYHOUSE.ZZT"); nil
File.open("game.json", "w"){|f| f.write game.to_json}
puts game.to_json


json = JSON::load(IO.read("./game.json"))
zgame = ZZTGame.from_json(json)

debugger
obj_parser = ZZTParser.new([])
zgame.boards.last.objects[1].to_bytes(obj_parser)

tile_parser = ZZTParser.new([])
zgame.boards.last.tiles[0].parsers = [ZZTParser.allocate]
zgame.boards.last.tiles[0].parser.hex_array = []
zgame.boards.last.tiles[0].to_bytes(tile_parser)

board_parser = ZZTParser.new([])
zgame.boards.last.to_bytes(board_parser)
x = 2-1



=begin
obj.data; obj.data_len; obj.hex_code_values; obj.hex_code_values.length; obj.bounds
=end
