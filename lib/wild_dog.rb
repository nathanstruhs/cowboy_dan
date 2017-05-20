class WildDog
  attr_reader :x_dog, :y_dog

  def initialize x, y
    @standing, @walk_1, @walk_2 = *Gosu::Image.load_tiles("../assets/images/sprites/wild_dog.png", 40, 20)
    @x_dog, @y_dog = x, y
    @direction = :left
    @current_image = @standing
  end

  def draw
    if @direction == :left
      offset_x = -25
      factor = 1.0
    else
      offset_x = 25
      factor = -1.0
    end
    @current_image.draw(@x_dog + offset_x, @y_dog - 20, 0, factor, 1.0)
  end

  def update move_x
    if move_x == 0
      @current_image = @standing
    else
      @current_image = (Gosu.milliseconds / 175 % 2 == 0) ? @walk_1 : @walk_2
    end

    if move_x > 0
      @direction = :right
      move_x.times { @x_dog += 1 }
    end

    if move_x < 0
      @direction = :left
      (-move_x).times { @x_dog -= 1 }
    end
  end
end