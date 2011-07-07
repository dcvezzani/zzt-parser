require File.dirname(__FILE__) + "/../models/zzt_base"

class ZZTGameHeader < ZZTBase
 
  attr_accessor :board_cnt, :ammo_cnt, :gems_cnt, :keys, :health_cnt, \
    :board_start, :torches_cnt, :torch_cycle_cnt, :ener_cycle_cnt, \
    :unk_01, :score_cnt, :world_title, :flags, :timer_cnt, :unk_02, \
    :saved_game

  KEYS = %w{blue green cyan red purple yellow white}
  FLAGS_CNT = 10

  def initialize(parser, *args)
    super(parser)
    #hash of keys, initialized to false
    @keys = KEYS.inject({}){|a,b| a.merge(b.to_sym() => false) }
    @flags = [0..FLAGS_CNT].map{|x| nil}
  end

  def self.parse(parser)
    header = ZZTGameHeader.new(parser)

    header.read(:n0, "board_cnt", 2)

    %w{ammo_cnt gems_cnt}.each{|attr|
      header.read(:n, attr, 2)
    }

    header.parse_keys(parser)

    %w{health_cnt board_start 
      torches_cnt torch_cycle_cnt ener_cycle_cnt unk_01 score_cnt}.each{|attr|
      header.read(:n, attr, 2)
    }

    header.read(:s, "world_title", 20)

    header.parse_flags(parser)

    %w{timer_cnt unk_02}.each{|attr|
      header.read(:n, attr, 2)
    }
    
    header.read(:n, "saved_game", 1)

    header
  end

  def parse_flags(parser)
    @flags = (0...FLAGS_CNT).map{|x|
      flag = read(:bs, nil, 20, "flag_#{x.to_s.rjust(2, '0')}")
      flag
    }
  end

  def parse_keys(parser)
    @keys = KEYS.inject({}){|hash, color|
      player_has_key = read(:tf, nil, 1, "key_#{color}")
      hash.merge(color.to_sym() => player_has_key)
    }
  end
end
