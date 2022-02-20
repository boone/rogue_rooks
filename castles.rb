# frozen_string_literal: true

# Castles Game
# Gosu Game Jam 2
# February 2022

# Mike Boone
# https://twitter.com/boonedocks
# https://github.com/boone

require "gosu"

class CastlesGame < Gosu::Window
  def initialize
    super 600, 650
    
    self.caption = "Castles!"
    
    @board = Gosu::Image.new("images/4x4_board.png", tileable: true)
    # @npcs = []
    q1 = Queen.new(0, 0)
    q2 = Queen.new(10, 5)
    @npcs = [q1, q2]
    @time_check = Time.now
    @song = Gosu::Song.new("sounds/song_test.wav")
    @song.volume = 0.15
    @song.play(true)
    @score = 0
  end
  
  def update
    if Time.now - @time_check > 0.5
      @npcs.each do |npc|
        npc.x += 1
        npc.x = 0 if npc.x > 11
        npc.y += 1
        npc.y = 0 if npc.y > 8
      end
      @time_check = Time.now
    end
    # puts @song.volume
  end

  def draw
    (0..9).each do |x|
      (0..5).each do |y|
        @board.draw(x * 100 - 1, y * 100 - 1 + 50, 0)
      end
    end
    
    @npcs.each do |npc|
      npc.image.draw(npc.x * 50, npc.y * 50 + 50, 1)
    end
  end
end

class Queen
  attr_accessor :x, :y, :image, :vel_x, :vel_y
  
  # needs: current position, goal, 
  
  def initialize(x, y)
    @x = x
    @y = y
    @image = Gosu::Image.new("images/queen.png", tileable: false)
    @vel_x = 0
    @vel_y = 0
  end
end

CastlesGame.new.show
