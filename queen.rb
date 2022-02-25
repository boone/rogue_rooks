# frozen_string_literal: true

class Queen
  attr_accessor :x, :y, :image

  def initialize(x, y)
    @x = x
    @y = y

    @image = Gosu::Image.new("images/queen.png", tileable: true)

    RogueRooks.occupy_square(x, y)
  end

  def move_closer
    # TODO this should actually target an available rook, not just the center
    diff_x = 7.5 - @x
    diff_y = 7.5 - @y

    # I think this math might be backwards, but it's currently working
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
