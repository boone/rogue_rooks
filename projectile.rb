# frozen_string_literal: true

class Projectile
  attr_accessor :target_x, :target_y, :pixel_x, :pixel_y, :image, :rotation, :done

  def initialize(target_x, target_y)
    # +25 (half the square) centers the target

    half_square_size = RogueRooks::SQUARE_SIZE / 2
    @target_x = target_x + half_square_size
    @target_y = target_y + half_square_size

    @pixel_x = 7.5 * RogueRooks::SQUARE_SIZE.to_f + half_square_size
    @pixel_y = 7.5 * RogueRooks::SQUARE_SIZE.to_f + RogueRooks::INFO_BAR_HEIGHT + half_square_size

    diff_x = @target_x - @pixel_x
    diff_y = @target_y - @pixel_y

    @angle = Math.atan2(diff_y, diff_x)

    @rotation = @angle / (Math::PI / 180.0) + 180
    @image = Gosu::Image.new("images/fireball.png", tileable: true)
    @velocity = 150.0 # pixels/second

    launch = Gosu::Sample.new("sounds/launch.wav")
    launch.play
    @done = false
  end

  def move_closer
    if (@target_x - @pixel_x).abs < 2.0 &&
      (@target_y - @pixel_y).abs < 2.0
      @done = true
      return
    end

    distance = @velocity / Gosu.fps

    new_diff_x = distance * Math.cos(@angle)
    new_diff_y = distance * Math.sin(@angle)

    @pixel_x += new_diff_x
    @pixel_y += new_diff_y
  end
end
