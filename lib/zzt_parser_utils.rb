require 'logger'

module ZZTParserUtils
  LOG = Logger.new("zzt-parser.log")
  LOG.level = Logger::DEBUG

  def self.hex_to_dec(hex_str)
    hex_str.to_i(16)
  end

  def self.hex_to_ascii(hex_str)
    hex_str.scan(/../).map{ |tuple| tuple.hex.chr }.join("")
  end

  def read_bytes(max_len, label="bytes")
    read_hex_array(max_len, false, label)
#   {|bytes|
#     res = ZZTParserUtils.hex_to_dec(bytes.join(""))
#     res
#   }
  end

  def read_number(max_len, zero_based=false, label="bytes")
    read_hex_array(max_len, true, label){|bytes|
      res = ZZTParserUtils.hex_to_dec(bytes.join(""))
      res = (zero_based) ? (res+1) : res
      #(res+1) # add 1 because number of boards is zero-based
    }
  end

  def read_string(max_len, label="bytes", str_len=nil)
    unless(str_len)
      str_len = read_hex_array(1, true, "#{label}_len"){|bytes|
        res = ZZTParserUtils.hex_to_dec(bytes.join(""))
        res
      }
    end

    str_buffer = read_hex_array(max_len, false, label){|bytes|
      res = ZZTParserUtils.hex_to_ascii(bytes.join(""))
      res
    }
    str_buffer.slice(0, str_len)
  end

  def read_hex_array(bytes, rev=true, label="bytes", &blk)
    out = []

    res = @hex_array.slice!(0, bytes)
    out << [label, res.inspect]

    res.reverse! if rev

    res = (block_given?) ? blk.call(res) : res
    out << "'#{res.to_s}'"

    if(label and !label.match(/raw/))
      LOG.debug out.join(" - ") 
    end

    res
  end

  def parse_attributes(parser, attr_arr)
    attr_arr.each{|attr|
      self.send("#{attr}=".to_sym(), parser.read_hex_array(2, true, attr){|bytes|
        res = ZZTParserUtils.hex_to_dec(bytes.join(""))
        res
      })
    }
  end
end
