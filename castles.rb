# frozen_string_literal: true

# Rogue Rooks
# Castles Theme
# Gosu Game Jam 2
# February 2022

# Mike Boone
# https://twitter.com/boonedocks
# https://github.com/boone
# https://boone42.itch.io

require "gosu"

class RogueRooks < Gosu::Window
  def initialize
    super 800, 850
    
    self.caption = "Castles!"
    
    @board = Gosu::Image.new("images/4x4_board.png", tileable: true)
    @target = Gosu::Image.new("images/target.png", tileable: true)
    # @npcs = []
    q1 = Queen.new(1, 15, 1)
    q2 = Queen.new(15, 10, -1)
    @npcs = [q1, q2]
    @time_check = Time.now
    @song = Gosu::Song.new("sounds/song_test.wav")
    @song.volume = 0.15
    @song.play(true)
    @score = 0
    
    r1 = PlayerRook.new(7, 7)
    r2 = PlayerRook.new(8, 7)
    r3 = PlayerRook.new(7, 8)
    r4 = PlayerRook.new(8, 8)
    @player_rooks = [r1, r2, r3, r4]
    
    @target_x = nil; @target_y = nil
    
    @title_font = Gosu::Font.new(40, italic: true)
    @about_font = Gosu::Font.new(20)
    @show_about = true
  end

  def button_down(button_id)
    if button_id == Gosu::MS_LEFT
      @show_about = false
    end
  end
  
  def update
    if @show_about
      @song.volume = 0.05
      return
    else
      @song.volume = 0.15
    end
    
    # place target
    if mouse_x >= 0 && mouse_x <= width &&
      mouse_y >= 50 && mouse_y <= height
      
      @target_x = (mouse_x / 50).floor * 50
      @target_y = (mouse_y / 50).floor * 50
    else
      @target_x = nil
      @target_y = nil
    end
    
    if Time.now - @time_check > 2
      @npcs.each do |npc|
        npc.move_closer

        # npc.x += 1 * npc.dir
        # npc.x = 0 if npc.x > 15
        # npc.x = 15 if npc.x < 0
        # npc.y += 1 * npc.dir
        # npc.y = 0 if npc.y > 15
        # npc.y = 15 if npc.y < 0
        
        @player_rooks.each_with_index do |player_rook, i|
          if npc.x == player_rook.x && npc.y == player_rook.y
            # todo explosion graphic and sound
            @player_rooks.delete_at(i)
          end
        end
      end
      @time_check = Time.now
    end
    # puts @song.volume
  end

  def draw
    @title_font.draw_text("Rogue Rooks", 5, 5, 100)

    if @show_about
      my_text = <<~EOF
        Made for the Gosu Game Jam 2 in February 2022

        By Mike Boone
        https://twitter.com/boonedocks
        https://github.com/boone
        https://boone42.itch.io
      EOF

      @about_font.draw_text(my_text, 5, 55, 100)
      @about_font.draw_text(Gosu::LICENSES, 5, 555, 100)
      
      return
    end

    if @target_x && @target_y
      @target.draw(@target_x, @target_y, 3)
    end
    
    (0..8).each do |x|
      (0..8).each do |y|
        @board.draw(x * 100 - 1, y * 100 - 1 + 50, 0)
      end
    end
    
    @npcs.each do |npc|
      npc.image.draw(npc.x * 50, npc.y * 50 + 50, 1)
    end
    
    @player_rooks.each do |player_rook|
      player_rook.image.draw(player_rook.x * 50, player_rook.y * 50 + 50, 2)
    end
  end
end

class Queen
  attr_accessor :x, :y, :image, :vel_x, :vel_y, :dir
  
  # needs: current position, goal, 
  
  def initialize(x, y, dir)
    @x = x
    @y = y
    @image = Gosu::Image.new("images/queen.png", tileable: true)
    @vel_x = 0
    @vel_y = 0
    @dir = dir || 1
  end
  
  def move_closer
    # if the square is occupied by another npc, skip this turn
    # take one step closer
    # find angle to center

    diff_x = 7.5 - @x
    diff_y = 7.5 - @y

    angle = Math.atan2(diff_x, diff_y) / (Math::PI / 180.0)

    move = if angle >= -22.5 && angle < 22.5
      { x: 0, y: 1 } # s
    elsif angle >= 22.5 && angle < 67.5
      { x: 1, y: 1 } # se
    elsif angle >= 67.5 && angle < 112.5
      { x: 1, y: 0 } # e
    elsif angle >= 112.5 && angle < 157.5
      { x: 1, y: -1 } # ne
    elsif angle >= 157.5 || angle < -157.5
      { x: 0, y: -1 } # n
    elsif angle >= -157.5 && angle < -112.5
      { x: -1, y: -1 } # nw
    elsif angle >= -112.5 && angle < -67.5
      { x: -1, y: 0 } # w
    elsif angle >= -67.5 && angle < -22.5
      { x: -1, y: 1 } # sw
    end

    @x += move[:x]
    @y += move[:y]
  end
end

class PlayerRook
  attr_accessor :x, :y, :damage, :image
  
  def initialize(x, y)
    @x = x
    @y = y
    @damage = 0
    @image = Gosu::Image.new("images/rook.png", tileable: true)
  end
end


RogueRooks.new.show
