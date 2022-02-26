# frozen_string_literal: true

# Rogue Rooks
# Castles Theme
# Gosu Game Jam 2
# February 2022
# https://itch.io/jam/gosu-game-jam-2

# Mike Boone
# https://twitter.com/boonedocks
# https://github.com/boone
# https://boone42.itch.io

require "gosu"
require_relative "rook"
require_relative "queen"
require_relative "knight"
require_relative "projectile"

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

  GAME_OVER_WAIT = 1 # in seconds

  def self.reset_occupied
    @@occupied = {}
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

    @title_font = Gosu::Font.new(40, italic: true)
    @score_font = Gosu::Font.new(30, bold: true)
    @about_font = Gosu::Font.new(20)
    @license_font = Gosu::Font.new(15)

    @song.volume = 0.15
    @song.play(true)

    @show_about = true
  end

  def button_down(button_id)
    if button_id == Gosu::MS_LEFT
      if @show_about
        @show_about = false
        new_game
      elsif @game_over && @game_over_wait_done
        new_game
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
    update_time = Time.now # so we don't keep calculating

    if @show_about
      @song.volume = 0.05
      return
    elsif @game_over
      @song.volume = 0.05
      @game_over_time ||= update_time

      if @game_over_time + GAME_OVER_WAIT < update_time
        @game_over_wait_done = true
      end

      return
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

      next unless projectile.done

      @projectiles.delete_at(i)
      @npcs.each_with_index do |npc, j|
        square_target_x = projectile.target_x / SQUARE_SIZE
        square_target_y = (projectile.target_y - INFO_BAR_HEIGHT) / SQUARE_SIZE

        if npc.x == square_target_x && npc.y == square_target_y
          RogueRooks.leave_square(npc.x, npc.y)
          @score += npc.class::POINT_VALUE
          @npcs.delete_at(j)
        end
      end
    end

    @npcs.each do |npc|
      next unless update_time - npc.last_move_time > npc.class::SPEED

      npc.move_closer

      @player_rooks.each_with_index do |player_rook, i|
        if npc.x == player_rook.x && npc.y == player_rook.y
          # todo explosion graphic and sound
          @player_rooks.delete_at(i)
        end
      end

      game_over if @player_rooks.count == 0
    end

    if update_time - @last_spawn > @spawn_rate
      spawn_new_npc
      # new_npc_class = [Queen, Knight, Knight].sample # duplication is for overweighting
      #
      # new_row_col = (0..15).to_a.sample
      # x_y = [true, false].sample
      # left_right_top_bottom = [0, 15].sample
      #
      # new_position = if x_y
      #   [new_row_col, left_right_top_bottom]
      # else
      #   [left_right_top_bottom, new_row_col]
      # end
      #
      # unless RogueRooks.occupied_square?(*new_position)
      #   @npcs << new_npc_class.new(*new_position)
      #   @last_spawn = update_time
      # end
    end
  end

  def draw
    @title_font.draw_text(TITLE, 5, 5, Z_LEVEL[:text])
    score_width = @score_font.text_width(@score)
    @score_font.draw_text(@score, width - score_width - 5, 10, Z_LEVEL[:text])
    #@score_font.draw_text(Gosu.fps, 400, 10, Z_LEVEL[:text])
    @score_font.draw_text(@projectiles.count, 400, 10, Z_LEVEL[:text])

    if @show_about
      my_text = <<~EOF
        Made for the Gosu Game Jam 2 in February 2022

        https://itch.io/jam/gosu-game-jam-2

        By Mike Boone
        https://twitter.com/boonedocks
        https://github.com/boone
        https://boone42.itch.io

        The rooks do not want to play chess anymore. The other pieces are angry!

        Save your rooks by shooting fireballs at the attacking chess pieces.

        Click to play!
      EOF

      @about_font.draw_text(my_text, 10, 75, Z_LEVEL[:text])
      @license_font.draw_text(Gosu::LICENSES, 10, 770, Z_LEVEL[:text])

      return
    end

    if @target_x && @target_y
      @target.draw(@target_x, @target_y, Z_LEVEL[:target])
    end

    @projectiles.each do |projectile|
      projectile.image.draw_rot(projectile.pixel_x, projectile.pixel_y,
        Z_LEVEL[:projectile], projectile.rotation)
    end

    (0..8).each do |x|
      (0..8).each do |y|
        @board.draw(x * SQUARE_SIZE * 2 - 1,
          y * SQUARE_SIZE * 2 - 1 + INFO_BAR_HEIGHT, Z_LEVEL[:board])
      end
    end

    @npcs.each do |npc|
      npc.image.draw(npc.x * SQUARE_SIZE, npc.y * SQUARE_SIZE + INFO_BAR_HEIGHT,
        Z_LEVEL[:npc])
    end

    @player_rooks.each do |player_rook|
      player_rook.image.draw(player_rook.x * SQUARE_SIZE,
        player_rook.y * SQUARE_SIZE + INFO_BAR_HEIGHT, Z_LEVEL[:rook])
    end

    if @game_over
      game_over_text = "Game over!"
      game_over_text_width = @score_font.text_width(game_over_text)

      # draw semi-opaque square over game
      game_over_square_color = Gosu::Color.rgba(100, 100, 100, 200)
      Gosu.draw_rect(0, INFO_BAR_HEIGHT, GAME_WIDTH, GAME_HEIGHT, game_over_square_color, Z_LEVEL[:text] - 1)

      @score_font.draw_text(game_over_text, GAME_WIDTH / 2 - game_over_text_width / 2, 220, Z_LEVEL[:text])

      if @game_over_wait_done
        click_text = "Click to play again"
        click_text_width = @score_font.text_width(click_text)
        @score_font.draw_text(click_text, GAME_WIDTH / 2 - click_text_width / 2, 600, Z_LEVEL[:text])
      end
    end
  end

  private

  def new_game
    RogueRooks.reset_occupied

    @score = 0
    @game_over = false
    @game_over_time = nil

    @npcs = []
    @projectiles = []

    # initial attackers
    4.times { spawn_new_npc }

    r1 = Rook.new(7, 7)
    r2 = Rook.new(8, 7)
    r3 = Rook.new(7, 8)
    r4 = Rook.new(8, 8)
    @player_rooks = [r1, r2, r3, r4]

    @spawn_rate = 4.0 # 1 every @spawn_rate seconds

    @shoot_delay = Time.now
    @last_spawn = Time.now
  end

  def game_over
    @game_over = true
    @game_over_wait_done = false
  end

  def increase_spawn_rate
    @spawn_rate -= 0.1

    @spawn_rate = [@spawn_rate, 1.0].max
  end

  def spawn_new_npc
    new_npc_class = [Queen, Knight, Knight].sample # duplication is for overweighting

    new_row_col = (0..15).to_a.sample
    x_y = [true, false].sample
    left_right_top_bottom = [0, 15].sample

    new_position = if x_y
      [new_row_col, left_right_top_bottom]
    else
      [left_right_top_bottom, new_row_col]
    end

    unless RogueRooks.occupied_square?(*new_position)
      @npcs << new_npc_class.new(*new_position)
      @last_spawn = Time.now
    end
  end
end

RogueRooks.new.show
