require 'ruby-debug'
require 'json'
load './lib/zzt_parser_utils.rb'
load './models/zzt_base.rb'
load './models/zzt_game.rb'
load './zzt_parser.rb'
load './models/zzt_game_header.rb'
load './models/zzt_board_tile.rb'
load './models/zzt_board_tiles.rb'
load './models/zzt_game_board.rb'
load './models/zzt_object.rb'
load './models/zzt_objects.rb'

Dir.glob('./models/zzt_objects/*.rb').each do |file|
  load file
end


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
  load './models/zzt_objects.rb'

  Dir.glob('./models/zzt_objects/*.rb').each do |file|
    load file
  end

  game = ZZTParser.parse(filename)
  # game.to_json
  # puts game.header.inspect
  # puts game.boards.first.inspect
  game
end

#game = zzt_reload("../townb.zzt"); nil

=begin
game = zzt_reload("/Users/davidvezzani/DOS\ Games/Zzt.boxer/C.harddisk/zzt/MYHOUSE.ZZT"); nil
File.open("game.json", "w"){|f| f.write game.to_json}
puts game.to_json
=end

zgame = ZZTParser.parse("/Users/davidvezzani/DOS\ Games/Zzt.boxer/C.harddisk/zzt/DCVTEST.ZZT")
File.open("zzt-dcvtest.json", "w"){|f| f.write zgame.to_json}


json = JSON::load(IO.read("./zzt-dcvtest.json"))
zgame = ZZTGame.from_json(json)

board_tiles_snap = []
zgame.boards.last.tiles.each do |tile|
  tile_parser = ZZTParser.new([])
  tile.to_bytes(tile_parser)
  board_tiles_snap << tile_parser.hex_array.clone
  #debugger if tile_parser.hex_array.include?(nil)
end
board_tiles_snap.flatten.length

debugger
zgame.boards.last.objects << ZZTObjects::Scroll.new(ZZTParser.new([]), 1)

zgame.boards.last.objects.last.x=10
zgame.boards.last.objects.last.y=10
zgame.boards.last.objects.last.data="Good grief!"

grid = zgame.boards.last.tiles_to_grid
debugger
grid.grid[10][10].code.value = '0A'

board_tiles = grid.to_board_tiles

zgame.boards.last.tiles = board_tiles

game_parser = ZZTParser.new([])
arr = zgame.to_bytes(game_parser).clone



board_tiles_snap = []
board_tiles.each do |tile|
  tile_parser = ZZTParser.new([])
  tile.to_bytes(tile_parser)
  board_tiles_snap << tile_parser.hex_array.clone
  #debugger if tile_parser.hex_array.include?(nil)
end
board_tiles_snap.flatten.length

game_parser.save_file("/Users/davidvezzani/DOS\ Games/Zzt.boxer/C.harddisk/zzt/DCVTEST2.ZZT")

grid


=begin

# obj_parser = ZZTParser.new([])
# zgame.boards.last.objects[1].to_bytes(obj_parser)
#
# tile_parser = ZZTParser.new([])
# zgame.boards.last.tiles[0].parsers = [ZZTParser.allocate]
# zgame.boards.last.tiles[0].parser.hex_array = []
# zgame.boards.last.tiles[0].to_bytes(tile_parser)
#
# board_parser = ZZTParser.new([])
# zgame.boards.last.to_bytes(board_parser)

debugger
player = ZZTObjects::Player.new(ZZTParser.new([]), 1)
player_parser = ZZTParser.new([])
player.to_bytes(player_parser)

scroll = ZZTObjects::Scroll.new(ZZTParser.new([]), 1)
scroll_parser = ZZTParser.new([])
scroll.to_bytes(scroll_parser)
scroll.x = 40
scroll.y = 15
scroll.data = "Greetings, program!"


#b /Users/davidvezzani/Desktop/desktop-archive/zzt/zzt/src/models/zzt_object.rb:74
o = zgame.boards.last.objects[4]
o.data = "@house_cleaner\r#end\r\r:touch\rWhat do you want cleaned?\r#end"

zgame.boards.last.objects << scroll

debugger
game_parser = ZZTParser.new([])
arr = zgame.to_bytes(game_parser).clone

res = []
while(arr.length > 0)
  res << arr.shift(32).join(" ")
end
#95li
File.open("chk.txt", "w"){|f| f.write(res.join("\n"))}


game_parser.save_file("/Users/davidvezzani/DOS\ Games/Zzt.boxer/C.harddisk/zzt/DCVTEST2.ZZT")

# debugger
# x=2-1

game_chk = ZZTParser.parse("/Users/davidvezzani/DOS\ Games/Zzt.boxer/C.harddisk/zzt/DCVTEST2.ZZT")

debugger
x=2-1
=end


=begin
obj.data; obj.data_len; obj.hex_code_values; obj.hex_code_values.length; obj.bounds


@house_cleaner\r#end\r
@house_cleaner\r#end\r\r:touch\rWhat do you want cleaned?\r#end
What do you want cleaned?
=end
