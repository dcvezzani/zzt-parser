require File.dirname(__FILE__) + "/../models/zzt_base"

class ZZTBoardTile < ZZTBase

  class Code
    attr_accessor :value, :description, :num
    def initialize(value, description, num)
      @value = value
      @description = description
      @num = num
    end

    def is_text?
      (@num >= 47 and @num <= 61)
    end
  end

  attr_accessor :cnt, :code, :color, :ascii

  COLOR = {
    "00" => "Black", 
    "01" => "Dark blue", 
    "02" => "Dark green", 
    "03" => "Dark cyan", 
    "04" => "Dark red", 
    "05" => "Dark purple", 
    "06" => "Dark yellow (brown)", 
    "07" => "Light grey", 
    "08" => "Dark grey", 
    "09" => "Light blue", 
    "0A" => "Light green", 
    "0B" => "Light cyan", 
    "0C" => "Light red", 
    "0D" => "Light purple", 
    "0E" => "Light yellow", 
    "0F" => "White"
  }
    #"20" => "Gold"

  CODE = {
     "00" => ["00", "Empty Space"], 
     "01" => ["00", "Special: acts like edge of board"], 
     "04" => ["02", "Player"], 
     "05" => ["84", "Ammo"], 
     "06" => ["9D", "Torch"], 
     "07" => ["04", "Gem"], 
     "08" => ["0C", "Key"], 
     "09" => ["0A", "Door"], 
     "0A" => ["E8", "Scroll"], 
     "0B" => ["F0", "Passage"], 
     "0C" => ["(growing O)", "Duplicator"], 
     "0D" => ["0B", "Bomb"], 
     "0E" => ["7F", "Energizer"], 
     "0F" => ["(spins)", "Star"], 
     "10" => ["(spins)", "Clockwise conveyer"], 
     "11" => ["(spins)", "Counterclockwise conveyor"], 
     "12" => ["F8", "Bullet"], 
     "13" => ["B0", "Water"], 
     "14" => ["B0", "Forest"], 
     "15" => ["DB", "Solid"], 
     "16" => ["D2", "Normal"], 
     "17" => ["B1", "Breakable"], 
     "18" => ["FF", "Boulder"], 
     "19" => ["12", "Slider: North-South"], 
     "1A" => ["1D", "Slider: East-West"], 
     "1B" => ["B2", "Fake"], 
     "1C" => ["(invisible)", "Invisible wall"], 
     "1D" => ["(varies)", "Blink Wall"], 
     "1E" => ["(varies)", "Transporter"], 
     "1F" => ["(varies)", "Line"], 
     "20" => ["2A", "Ricochet"], 
     "21" => ["CD", "Horizontal blink wall ray"], 
     "22" => ["99", "Bear"], 
     "23" => ["05", "Ruffian"], 
     "24" => ["(varies)", "Object"], 
     "25" => ["2A", "Slime"], 
     "26" => ["5E", "Shark"], 
     "27" => ["(spins)", "Spinning gun"], 
     "28" => ["(varies)", "Pusher"], 
     "29" => ["EA", "Lion"], 
     "2A" => ["E3", "Tiger"], 
     "2B" => ["BA", "Vertical blink wall ray"], 
     "2C" => ["E9", "Centipede head"], 
     "2D" => ["4F", "Centipede segment"], 
     "2F" => ["(set in colour byte)", "Blue text"], 
     "30" => ["(set in colour byte)", "Green text"], 
     "31" => ["(set in colour byte)", "Cyan text"], 
     "32" => ["(set in colour byte)", "Red text"], 
     "33" => ["(set in colour byte)", "Purple text"], 
     "34" => ["(set in colour byte)", "Yellow text"], 
     "35" => ["(set in colour byte)", "White text"], 
     "36" => ["(set in colour byte)", "White blinking text"], 
     "37" => ["(set in colour byte)", "Blue blinking text"], 
     "38" => ["(set in colour byte)", "Green blinking text"], 
     "39" => ["(set in colour byte)", "Cyan blinking text"], 
     "3A" => ["(set in colour byte)", "Red blinking text"], 
     "3B" => ["(set in colour byte)", "Purple blinking text"], 
     "3C" => ["(set in colour byte)", "Yellow blinking text"], 
     "3D" => ["(set in colour byte)", "Grey blinking text"]
  }

  def initialize(parser)
    super
    self.parsers << parser
  end

  def read_code_and_description #1 byte
    code_value, code_description, code_num = parser.read_hex_array(1, false, "tile_code"){|bytes|
      res = ZZTParserUtils.hex_to_dec(bytes.join(""))
      
      [bytes.join(""), CODE[bytes.join("")], res]
    }

    @code = Code.new(code, code_description, code_num)
  end

  def read_text #1 byte
    @ascii = parser.read_hex_array(1, true, "tile_ascii"){|bytes|
      bytes.join("").hex.chr
    }
  end

  def read_color #1 byte
    @color = parser.read_hex_array(1, true, "tile_color"){|bytes|
      COLOR[bytes.join("")]
    }
  end

  def self.parse(parser)
    tile = ZZTBoardTile.new(parser)

    tile.read(:n, "cnt", 1, "tile_cnt")
    tile.read_code_and_description #1 byte
    
    if(tile.code.is_text?)
      tile.read_text
    else
      tile.read_color
    end

    tile
  end

end

