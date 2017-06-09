class Steam
  attr_accessor :x, :y 

  def initialize x, y
    @x = x
    @y = y
    @s1, @s2, @s3, @s4, @s5, @s6, @s7, @s8 = *Gosu::Image.load_tiles("../assets/images/sprites/steamin.png", 100, 100)
    @current_image = @s1
  end

  def draw
    @current_image.draw(@x, @y, 1, 1)
  end

  def is_steamin(counter)
    counter = counter % 136
    if counter.between?(0,16)
      @current_image = @s1
    elsif counter.between?(17,32)
      @current_image = @s2
    elsif counter.between?(33,48)
      @current_image = @s3
    elsif counter.between?(49,64)
      @current_image = @s4
    elsif counter.between?(45,80)
      @current_image = @s5
    elsif counter.between?(81,96)
      @current_image = @s6
    elsif counter.between?(97, 112)
      @current_image = @s7
    else
      @current_image = @s8
    end
  end
end