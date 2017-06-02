class Bear
  attr_accessor :x, :y

  def initialize(x, y)
    @x, @y = x, y
    @direction = :right
    @standing_1, @standing_2 = *Gosu::Image.load_tiles("../assets/images/sprites/bear.png", 90, 90)
    @current_image = @standing_1
  end

  def draw
    if @direction == :right
      offset_x = -35
      factor = 1.0
    else
      offset_x = 35
      factor = -1.0
    end
    @current_image.draw(@x + offset_x, @y - 73, 0, factor, 1.0)
  end


  def is_just_resting(counter)
    tens_place = counter.to_s.split('')
    if (tens_place[-2].to_i.odd?)
      @current_image = @standing_2
    else 
      @current_image = @standing_1
    end
  end


  def update
  end
end