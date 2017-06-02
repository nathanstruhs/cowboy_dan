class Cacti
  attr_accessor :x, :y 

  def initialize x, y
    @x = x
    @y = y
    @image = Gosu::Image.new("../assets/images/sprites/cacti.png")
  end

  def draw
    @image.draw(@x, @y, 1, 1)
  end

  def update
  end
end