# frozen_string_literal: true

class Rook
  attr_accessor :x, :y, :image

  def initialize(x, y)
    @x = x
    @y = y
    @image = Gosu::Image.new("images/rook.png", tileable: true)
  end
end
