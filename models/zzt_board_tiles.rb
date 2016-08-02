class ZZTBoardTiles

  attr_accessor :grid

  def initialize(board_tiles)
    # 60 * 25
    # attr_accessor :cnt, :code, :color, :ascii

    @grid = []
    cur_col = 0
    cur_row = 0
    tot_tiles = 0
    board_tiles.each do |board_tile|
      (0...board_tile.cnt).map{ 
        @grid[cur_row] = [] if @grid[cur_row].nil?
        @grid[cur_row] << board_tile
        if(cur_col > 0 and ((cur_col % 59) == 0))
          cur_row += 1 
          cur_col = 0
        else
          cur_col += 1 
        end
        tot_tiles += 1
      }
    end
  end

  def to_board_tiles
    board_tiles = []

    cnt = 0
    prev_board_tile = @grid.first.first
    tot_cnt = 0

    @grid.flatten.each do |board_tile|
      if(board_tile == prev_board_tile)
        cnt += 1 
      else
        prev_board_tile.cnt = cnt
        tot_cnt += cnt

        board_tiles << prev_board_tile
        cnt = 1
      end

      prev_board_tile = board_tile
    end

    prev_board_tile.cnt = cnt
    tot_cnt += cnt
    board_tiles << prev_board_tile

    raise "board tiles were not properly parsed; expected 1500 tiles; got #{tot_cnt}" unless (1500 == tot_cnt)
    board_tiles
  end

  def to_s
    res = (0...25).map do |cur_row|
      (0...60).map do |cur_col|
        code = @grid[cur_row][cur_col].code
        empty_or_marker = ((cur_row > 0 and (cur_row % 5) == 4 and (cur_col % 5) == 4) ? " ." : "  ")
        (code.value == "00") ? empty_or_marker : code.value
      end.join(" ")
    end

    header = (0...12).map do
      "              ."
    end.join("")

    "#{header}\n#{res.map.with_index{|row, i| (i > 0 and (i % 5) == 0) ? ".#{row}." : " #{row} "}.join("\n")}\n#{header}"
  end
end
