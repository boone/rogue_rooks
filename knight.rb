# frozen_string_literal: true

class Knight
  attr_accessor :x, :y, :image, :last_move_time

  POINT_VALUE = 50
  SPEED = 2.5 # move after this many seconds

  def initialize(x, y)
    @x = x
    @y = y
    @last_move_time = Time.now

    @image = Gosu::Image.new("images/knight.png", tileable: true)

    RogueRooks.occupy_square(x, y)
  end

  def move_closer
    # TODO this should actually target an available rook, not just the center
    diff_x = 7.5 - @x
    diff_y = 7.5 - @y

    angle = Math.atan2(diff_y, diff_x) / (Math::PI / 180.0)

    move = if angle >= 0 && angle < 45
      { x: 2, y: 1 } # ese
    elsif angle >= 45 && angle < 90
      { x: 1, y: 2 } # sse
    elsif angle >= 90 && angle < 135
      { x: -1, y: 2 } # ssw
    elsif angle >= 135 && angle <= 180
      { x: -2, y: 1 } # wsw
    elsif angle >= -180 && angle < -135
      { x: -2, y: -1 } # wnw
    elsif angle >= -135 && angle < -90
      { x: -1, y: -2 } # nnw
    elsif angle >= -90 && angle < -45
      { x: 1, y: -2 } # nne
    elsif angle >= -45 && angle < 0
      { x: 2, y: -1 } # ene
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

    @last_move_time = Time.now
  end
end
