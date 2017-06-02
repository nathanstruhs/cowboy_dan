class Player
  attr_accessor :x, :y, :health

  def initialize(map, x, y, wild_dogs, bear, cacti, hatchdoor)
    @x, @y = x, y
    @direction = :right
    @vertical_velocity = 0;
    @standing_1, @standing_2, @walk_1, @walk_2, @jump, @hurt = *Gosu::Image.load_tiles("../assets/images/sprites/cowboy-dan-sprite.png", 80, 80)
    @current_image = @standing_1
    @map = map
    @jump_sound = Gosu::Sample.new "../assets/fixtures/jump.mp3"
    @yeow = Gosu::Sample.new "../assets/fixtures/yeow.mp3"
    @wild_dogs = wild_dogs
    @health = 100
    @bear = bear
    @cacti = cacti
    @hatchdoor = hatchdoor
  end

  def draw
    if @direction == :right
      offset_x = -35
      factor = 1.0
    else
      offset_x = 35
      factor = -1.0
    end
    @current_image.draw(@x + offset_x, @y - 73, 50, factor, 1.0)
  end

  def would_fit(offset_x, offset_y)
    # Check at the center/top and center/bottom for map collisions
    not @map.solid?(@x + offset_x, @y + offset_y) and not @map.solid?(@x + offset_x, @y + offset_y - 60)
  end

  def is_just_resting(counter)
    tens_place = counter.to_s.split('')
    if (tens_place[-2].to_i.odd?)
      @current_image = @standing_2
    end
  end

  def doggy_collision
    @wild_dogs.each do |dog|
      if @x.between?(dog.x_dog - 30, dog.x_dog + 30) && @y.between?(dog.y_dog - 30, dog.y_dog + 30)
        @current_image = @hurt
        @yeow.play(0.4, 1.1, false)
        @health = @health - 5
        @vertical_velocity = -10
      end
    end
  end

  def cacti_collision
    @cacti.each do |cactus|
      if @x.between?(cactus.x - 10, cactus.x + 70) && @y.between?(cactus.y - 10, cactus.y + 80)
        @current_image = @hurt
        @yeow.play(0.4, 1.1, false)
        @health = @health - 5
        @vertical_velocity = -10
      end
    end
  end

  def near_bear?
    if @x.between?(@bear.x - 100, @bear.x + 20) && @y.between?(@bear.y - 30, @bear.y + 30) then return true end
  end

  def near_hatchdoor?
    if @x.between?(@hatchdoor.x - 100, @hatchdoor.x + 100) && @y.between?(@hatchdoor.y - 100, @hatchdoor.y + 100) then return true end
  end

  def update move_x
    if move_x == 0
      @current_image = @standing_1
    else
      @current_image = (Gosu.milliseconds / 175 % 2 == 0) ? @walk_1 : @walk_2
    end

    if @vertical_velocity < 0
      @current_image = @jump
    end

    if move_x > 0
      @direction = :right
      move_x.times { @x += 1 }
    end

    if move_x < 0
      @direction = :left
      (-move_x).times { @x -= 1 }
    end

    @vertical_velocity += 1
    if @vertical_velocity > 0
      @vertical_velocity.times { if would_fit(0, 1) then @y += 1 else @vertical_velocity = 0 end }
    end

    if @vertical_velocity < 0
      (-@vertical_velocity).times { if would_fit(0, -1) then @y -= 1 else @vertical_velocity = 0 end }
    end
  end

  def try_to_jump
    if @map.solid?(@x, @y + 1)
      @vertical_velocity = -20
      @jump_sound.play(0.2, 1.1, false)
    end
  end

end