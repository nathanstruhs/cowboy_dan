class Hatchdoor
  attr_accessor :x, :y 

  def initialize x, y
    @x = x
    @y = y
    @door_1, @door_2, @door_3 = *Gosu::Image.load_tiles("../assets/images/sprites/hatchdoor.png", 50, 50)
    @current_image = @door_1
  end

  def draw
    @current_image.draw(@x, @y, 1, 1)
  end

  def update
  end

  def is_stinkin(counter)
    counter = counter % 48
    if counter.between?(0,16)
      @current_image = @door_3 
    elsif counter.between?(17,32)
      @current_image = @door_2
    else counter.between?(33,48)
      @current_image = @door_1
    end
  end
end