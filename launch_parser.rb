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

  game = ZZTParser.parse(filename)
  # game.to_json
  # puts game.header.inspect
  # puts game.boards.first.inspect
  game
end

#game = zzt_reload("../townb.zzt"); nil
game = zzt_reload("/Users/davidvezzani/DOS\ Games/Zzt.boxer/C.harddisk/zzt/CADEN.ZZT"); nil
puts game.to_json


debugger
json = JSON::load(IO.read("./game.json"))
zgame = ZZTGame.from_json(json)
x = 2-1

