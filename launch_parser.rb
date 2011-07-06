def zzt_reload
[:Code].each{|x|
  begin
    ZZTObject.send(:remove_const, x)
  rescue
  end
}
[:ZZTBase, :ZZTObject, :ZZTBoardTile, :ZZTGameBoard, :ZZTGameHeader, :ZZTParser, :ZZTParserUtils].each{|x| 
  begin
    Object.send(:remove_const, x)
  rescue
  end
}
require 'ruby-debug'
load './lib/zzt_parser_utils.rb'
load './models/zzt_base.rb'
load './zzt_parser.rb'
load './models/zzt_game_header.rb'
load './models/zzt_board_tile.rb'
load './models/zzt_game_board.rb'
load './models/zzt_object.rb'

p = ZZTParser.parse
puts p.game_header.inspect
puts p.game_boards.first.inspect
p
end

p = zzt_reload; nil
