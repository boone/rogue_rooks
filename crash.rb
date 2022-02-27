# frozen_string_literal: true

class Crash
  attr_accessor :pixel_x, :pixel_y, :image, :rotation, :done

  def initialize(pixel_x, pixel_y)
    @pixel_x = pixel_x
    @pixel_y = pixel_y

    @start_time = Time.now

    @rotate_time = @start_time
    @rotate = 0

    @scale = 0.9
    @scale_time = @start_time

    @image = Gosu::Image.new("images/boom.png", tileable: true)

    @done = false
  end

  def draw
    @image.draw_rot(@pixel_x, @pixel_y, RogueRooks::Z_LEVEL[:crash],
      @rotate % 360, 0.5, 0.5, @scale, @scale)
  end

  def update
    update_time = Time.now

    if update_time - @start_time > 1
      @done = true
    end

    if update_time - @rotate_time > 0.025
      @rotate += 1
      @rotate_time = update_time
    end

    if update_time - @scale_time > 0.1
      @scale -= 0.1
      @scale_time = update_time
    end
  end
end
