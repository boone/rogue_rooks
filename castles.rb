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
  TITLE = "Rogue Rooks"

  Z_LEVEL = {
    board: 0,
    npc: 1,
    rook: 2,
    projectile: 3,
    target: 10,
    text: 100,
  }.freeze

  INFO_BAR_HEIGHT = 50
  GAME_WIDTH = 800
  GAME_HEIGHT = 800

  SQUARE_SIZE = 50

  # grid coordinates to top-left pixel
  def self.grid_to_pixel(grid_x, grid_y)
    # TODO
  end

  def self.occupy_square(grid_x, grid_y)
    #puts "occupying #{grid_x}, #{grid_y}"
    @@occupied ||= {}

    raise "Occupied! #{grid_x}, #{grid_y}" if @@occupied[[grid_x, grid_y]]

    @@occupied[[grid_x, grid_y]] = true
  end

  def self.leave_square(grid_x, grid_y)
    #puts "leaving #{grid_x}, #{grid_y}"
    @@occupied[[grid_x, grid_y]] = false
  end

  def self.occupied_square?(grid_x, grid_y)
    @@occupied && @@occupied[[grid_x, grid_y]] == true
  end

  def initialize
    super GAME_WIDTH, GAME_HEIGHT + INFO_BAR_HEIGHT

    self.caption = TITLE

    @board = Gosu::Image.new("images/4x4_board.png", tileable: true)
    @target = Gosu::Image.new("images/target.png", tileable: true)

    @song = Gosu::Song.new("sounds/song_test.wav")

    @npcs = []

    # q1 = Queen.new(1, 15)
    # q2 = Queen.new(15, 10)
    # @npcs = [q1, q2]

    (0..1).each do |i|
      @npcs << Queen.new(i, 0)
      @npcs << Queen.new(i + 14, 15)
      @npcs << Queen.new(15, i)
      @npcs << Queen.new(0, i + 14)
    end

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
    @score_font = Gosu::Font.new(30, bold: true)
    @about_font = Gosu::Font.new(20)
    @show_about = true
    @projectiles = []
    @shoot_delay = Time.now
  end

  def button_down(button_id)
    if button_id == Gosu::MS_LEFT
      if @show_about
        @show_about = false
      else
        if @projectiles.count < 6
          current_time = Time.now
          if current_time - @shoot_delay > 0.2
            @shoot_delay = current_time
            @projectiles << Projectile.new(@target_x, @target_y)
          end
        else
          # play out of ammo sounds?
        end
      end
    end
  end

  def update
    if @show_about
      @song.volume = 0.05
      return
    else
      @time_check ||= Time.now
      @song.volume = 0.15
    end

    # place target
    if mouse_x >= 0 && mouse_x <= width &&
      mouse_y >= INFO_BAR_HEIGHT && mouse_y <= height

      @target_x = (mouse_x / SQUARE_SIZE).floor * SQUARE_SIZE
      @target_y = (mouse_y / SQUARE_SIZE).floor * SQUARE_SIZE
    else
      @target_x = nil
      @target_y = nil
    end

    @projectiles.each_with_index do |projectile, i|
      projectile.move_closer

      if projectile.done
        @projectiles.delete_at(i)
        @npcs.each_with_index do |npc, j|
          square_target_x = projectile.target_x / SQUARE_SIZE
          square_target_y = (projectile.target_y - INFO_BAR_HEIGHT) / SQUARE_SIZE

          if npc.x == square_target_x && npc.y == square_target_y
            RogueRooks.leave_square(npc.x, npc.y)
            @npcs.delete_at(j)
            @score += 100
          end
        end
      end
    end

    if Time.now - @time_check > 2.5
      @npcs.each do |npc|
        npc.move_closer

        @player_rooks.each_with_index do |player_rook, i|
          if npc.x == player_rook.x && npc.y == player_rook.y
            # todo explosion graphic and sound
            @player_rooks.delete_at(i)
          end
        end
      end
      @time_check = Time.now
    end
  end

  def draw
    @title_font.draw_text(TITLE, 5, 5, Z_LEVEL[:text])
    score_width = @score_font.text_width(@score)
    @score_font.draw_text(@score, width - score_width - 5, 10, Z_LEVEL[:text])
    @score_font.draw_text(Gosu.fps, 400, 10, Z_LEVEL[:text])

    if @show_about
      my_text = <<~EOF
        Made for the Gosu Game Jam 2 in February 2022

        By Mike Boone
        https://twitter.com/boonedocks
        https://github.com/boone
        https://boone42.itch.io
      EOF

      @about_font.draw_text(my_text, 5, 55, Z_LEVEL[:text])
      @about_font.draw_text(Gosu::LICENSES, 5, 555, Z_LEVEL[:text])

      return
    end

    if @target_x && @target_y
      @target.draw(@target_x, @target_y, Z_LEVEL[:target])
    end

    @projectiles.each do |projectile|
      projectile.image.draw_rot(projectile.pixel_x, projectile.pixel_y,
        Z_LEVEL[:projectile], projectile.rot % 360)
    end

    (0..8).each do |x|
      (0..8).each do |y|
        @board.draw(x * SQUARE_SIZE * 2 - 1,
          y * SQUARE_SIZE * 2 - 1 + INFO_BAR_HEIGHT, Z_LEVEL[:board])
      end
    end

    @npcs.each do |npc|
      npc.image.draw(npc.x * 50, npc.y * 50 + INFO_BAR_HEIGHT, Z_LEVEL[:npc])
    end

    @player_rooks.each do |player_rook|
      player_rook.image.draw(player_rook.x * 50,
        player_rook.y * 50 + INFO_BAR_HEIGHT, Z_LEVEL[:rook])
    end
  end
end

class Queen
  attr_accessor :x, :y, :image, :vel_x, :vel_y

  def initialize(x, y)
    @x = x
    @y = y
    @image = Gosu::Image.new("images/queen.png", tileable: true)
    @vel_x = 0
    @vel_y = 0
    RogueRooks.occupy_square(x, y)
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

    # only move if the square is open
    orig_x = @x
    orig_y = @y

    new_x = @x + move[:x]
    new_y = @y + move[:y]

    unless RogueRooks.occupied_square?(new_x, new_y)
      RogueRooks.leave_square(orig_x, orig_y)

      @x = new_x
      @y = new_y

      RogueRooks.occupy_square(new_x, new_y)
    end
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

class Projectile
  attr_accessor :target_x, :target_y, :pixel_x, :pixel_y, :image, :rot, :done, :square

  def initialize(target_x, target_y)
    # +25 centers the target
    @target_x = target_x + 25
    @target_y = target_y + 25

    @pixel_x = 7.5 * 50.0 + 25
    @pixel_y = 7.5 * 50.0 + 50 + 25

    diff_x = @target_x - @pixel_x
    diff_y = @target_y - @pixel_y

    @angle = Math.atan2(diff_y, diff_x)

    @rot = @angle / (Math::PI / 180.0) + 180
    @image = Gosu::Image.new("images/fireball.png", tileable: true)
    @velocity = 150.0 # pixels/second

    launch = Gosu::Sample.new("sounds/launch.wav")
    launch.play
    @crash = Gosu::Sample.new("sounds/crash.wav")
    @done = false
  end

  def move_closer
    if (@target_x - @pixel_x).abs < 1.0 &&
      (@target_y - @pixel_y).abs < 1.0
      @crash.play
      @done = true
      return
    end

    distance = @velocity * 1 / 60.0 # TODO fix

    new_diff_x = distance * Math.cos(@angle)
    new_diff_y = distance * Math.sin(@angle)

    @pixel_x += new_diff_x
    @pixel_y += new_diff_y
  end
end

RogueRooks.new.show
