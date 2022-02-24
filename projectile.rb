# frozen_string_literal: true

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
