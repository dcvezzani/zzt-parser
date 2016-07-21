require 'logger'

class Fixnum
  def convert_base(to)
    self.to_s(to).to_i
  end
end

module ZZTParserUtils
  LOG = Logger.new("zzt-parser.log")
  LOG.level = Logger::DEBUG

  def self.hex_to_dec(hex_str)
    hex_str.to_i(16)
  end

  def self.hex_to_ascii(hex_str)
    hex_str.scan(/../).map{ |tuple| tuple.hex.chr }.join("")
  end

  def self.dec_to_hex(dec_int, len)
    res = dec_int.to_s(16)
    res = "0#{res}" if( (res.length % 2) == 1 )
    res = res.upcase.scan(/../)

    ensure_byte_array_length(res, len, {reverse: true})
  end

  def self.ascii_to_hex(ascii_str, len)
    res = ascii_str.chars.collect do |x|
      #x.match(/\d/) ? x : x.unpack('U')[0].to_s(16)
      x.unpack('U')[0].to_s(16).upcase.rjust(2, '0')
    end

    ensure_byte_array_length(res, len)
  end

  def self.ensure_byte_array_length(arr, len, options={reverse: false})
    while(arr.length < len)
      if options[:reverse]
        arr.unshift("00")
      else
        arr.push("00")
      end
    end

    arr
  end

  def write_bytes(bytes, len, label="bytes")
    bytes = ZZTParserUtils.ensure_byte_array_length(bytes, len)
    
    write_hex_array(bytes, false, label)
  end

  def write_number(num, len, label="bytes", options={zero_based: false})
    final_num = (options[:zero_based]) ? (num-1) : num
    bytes = ZZTParserUtils.dec_to_hex(final_num, len)

    write_hex_array(bytes, false, label)
  end

  def write_string(str, len, label="bytes")
    bytes = ZZTParserUtils.ascii_to_hex(str, len)

    write_hex_array(bytes, false, label)
  end

  def write_hex_array(bytes, rev=true, label="bytes", &blk)
    out = []

    out << [label, bytes.inspect]

    bytes.reverse! if rev

    bytes = (block_given?) ? blk.call(bytes) : bytes
    out << "'#{bytes.to_s}'"

    @hex_array.concat(bytes)

    if(label and !label.match(/raw/))
      LOG.debug out.join(" - ") 
    end

    bytes
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

    self.next_position += bytes

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
