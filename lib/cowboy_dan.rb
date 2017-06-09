require 'gosu'
require_relative 'map'
require_relative 'player'
require_relative 'wild_dog'
require_relative 'bear'
require_relative 'cacti'
require_relative 'hatchdoor'
require_relative 'steam'

WIDTH, HEIGHT = 1000, 610

module Tiles
  Grass = 0
  Earth = 1
end

class CowboyDan < Gosu::Window

  def initialize
    super WIDTH, HEIGHT
    self.caption = "Cowboy Dan"
    @sky = Gosu::Image.new("../assets/images/backgrounds/sky.jpg")
    @moonshine_operation = Gosu::Image.new("../assets/images/backgrounds/moonshine-operation.jpg")
    @start_screen = Gosu::Image.new("../assets/images/backgrounds/start_screen.jpg")
    @game_over_screen = Gosu::Image.new("../assets/images/backgrounds/game_over.jpg")
    @you_win_screen = Gosu::Image.new("../assets/images/backgrounds/you-win.jpg")
    @dialogue_box = Gosu::Image.new("../assets/images/sprites/dialogue.png")
    @dialogue_box_small = Gosu::Image.new("../assets/images/sprites/dialogue-small.png")
    @map = Map.new("../assets/fixtures/map.txt")
    @soundtrack = Gosu::Song.new "../assets/fixtures/soundtrack.mp3"
    @game_over_soundtrack = Gosu::Song.new "../assets/fixtures/game_over.mp3"
    @font = Gosu::Font.new(20, :name => "/Library/Fonts/AmericanTypewriter.ttc")
    @hud_display_font = Gosu::Font.new(40, :name => "/Library/Fonts/AmericanTypewriter.ttc")
    @xy_font = Gosu::Font.new(20, :name => "/Library/Fonts/AmericanTypewriter.ttc")
    @time_font = Gosu::Font.new(25, :name => "/Library/Fonts/AmericanTypewriter.ttc")

    @current_view = @start_screen
    @camera_x = @camera_y = 0
    @soundtrack.play(looping = true)
    @wild_dogs = [WildDog.new(1020, 450), WildDog.new(2100, 200), WildDog.new(3200, 249), WildDog.new(4380, 199),
                  WildDog.new(4580, 199), WildDog.new(5200, 599), WildDog.new(5400, 599)]
    @cacti = [Cacti.new(3750, 545), Cacti.new(500, 545), Cacti.new(550, 545), Cacti.new(1800, 295), Cacti.new(1830, 295), 
              Cacti.new(3250, 545), Cacti.new(6200, 545), Cacti.new(6250, 545), Cacti.new(6450, 545), Cacti.new(2585, 245),
              Cacti.new(2725, 245), Cacti.new(3375, 195), Cacti.new(6150, 545), Cacti.new(6050, 545),
              Cacti.new(5950, 545), Cacti.new(5850, 545) ]
    @bear = Bear.new(300, 590)
    @hatchdoor = Hatchdoor.new(6350, 552)
    @steam = Steam.new(11, 95)
    @dan = Player.new(@map, 50, 600, @wild_dogs, @bear, @cacti, @hatchdoor)
    @move_dog_x = 1
    @counter = 0
  end

  def reset
    @current_view = @game_over_screen
    @camera_x = @camera_y = 0
    @wild_dogs = [WildDog.new(1020, 450), WildDog.new(2100, 200), WildDog.new(3200, 249), WildDog.new(4380, 199),
                  WildDog.new(4580, 199)]
    @cacti = [Cacti.new(3750, 545), Cacti.new(500, 545), Cacti.new(550, 545), Cacti.new(1800, 295), Cacti.new(1830, 295), 
              Cacti.new(3250, 545), Cacti.new(6200, 545), Cacti.new(6250, 545), Cacti.new(6450, 545), Cacti.new(2585, 245),
              Cacti.new(2725, 245), Cacti.new(3375, 195), Cacti.new(6150, 545), Cacti.new(6050, 545),
              Cacti.new(5950, 545), Cacti.new(5850, 545) ]
    @dan = Player.new(@map, 50, 600, @wild_dogs, @bear, @cacti, @hatchdoor)
    @move_dog_x = 1
    @counter = 0
    @dan.health = 100
    @soundtrack.stop
    @game_over_soundtrack.play(looping = true)
  end

  def update
    move_x = 0
    move_x -= 5 if Gosu::button_down? Gosu::KB_LEFT
    move_x += 5 if Gosu::button_down? Gosu::KB_RIGHT
    @dan.update(move_x)
    @camera_x = [[@dan.x - WIDTH / 2, 0].max, @map.width * 50 - WIDTH].min

    @counter += 1
    if @counter % 100 == 0
      @move_dog_x *= -1
    end

    @wild_dogs.each { |dog| dog.update(@move_dog_x) }

    @dan.doggy_collision
    @dan.cacti_collision
    @dan.is_just_resting(@counter)
    @bear.is_just_resting(@counter)
    @hatchdoor.is_stinkin(@counter)

    if @dan.health < 0
      reset
    end

    if @current_view == @sky
      @game_over_soundtrack.stop
      @soundtrack.play(looping = true)
    end

    @steam.is_steamin(@counter)
  end

  def draw
    if @dan.near_bear?
      @dialogue_box.draw(320, 245, 1)
      @font.draw("Howdy Dan! Careful 'round",     360, 275, 3, 1, 1, Gosu::Color::BLACK)
      @font.draw("these parts. Theres wild",      360, 295, 3, 1, 1, Gosu::Color::BLACK)
      @font.draw("dogs and killer cacti about.",  360, 315, 3, 1, 1, Gosu::Color::BLACK)
      @font.draw("Oh! and I also heard",          360, 335, 3, 1, 1, Gosu::Color::BLACK)
      @font.draw("of a secret moonshine",         360, 355, 3, 1, 1, Gosu::Color::BLACK)
      @font.draw("operation, keep yer",           360, 375, 3, 1, 1, Gosu::Color::BLACK)
      @font.draw("eyes open fer it!",             360, 395, 3, 1, 1, Gosu::Color::BLACK)
      @font.draw("( hit space to enter it )",   360, 415, 3, 1, 1, Gosu::Color::BLACK)
    end

    if @current_view == @moonshine_operation
      @dialogue_box_small.draw(@dan.x + 20, @dan.y - 240, 1)
      @font.draw("I found it!", @dan.x + 50, @dan.y - 220, 3, 1, 1, Gosu::Color::BLACK)
      @font.draw("Yeeehaaaaw", @dan.x + 50, @dan.y - 200, 3, 1, 1, Gosu::Color::BLACK)
      @font.draw("\"Hit the space bar", @dan.x + 50, @dan.y - 180, 3, 1, 1, Gosu::Color::BLACK)
      @font.draw("end the game.\"", @dan.x + 50, @dan.y - 160, 3, 1, 1, Gosu::Color::BLACK)
    end

    if @current_view == @start_screen
      @start_screen.draw(0, 0, 0)
    elsif @current_view == @game_over_screen
      @game_over_screen.draw(0, 0, 0)
    elsif @current_view == @you_win_screen
      @you_win_screen.draw(0,0,0)
    else
      if @current_view == @moonshine_operation
        @moonshine_operation.draw(0, 0, -1)
        @dan.draw
        @map.draw
        @steam.draw
        @bear.y = 0
        @hatchdoor.y = 0
        @cacti.each { |cactus| cactus.y = 0 }
        @wild_dogs.each { |dog| dog.y_dog = 0 }
      else
        @sky.draw 0, 0, 0
        Gosu.translate(-@camera_x, -@camera_y) do
          @map.draw
          @dan.draw
          @bear.draw
          @hatchdoor.draw
          @cacti.each { |cactus| cactus.draw }
          @wild_dogs.each { |dog| dog.draw }
        end
      end

      @hud_display_font.draw("Health: #{@dan.health}", 20, 10, 3, 1, 1, Gosu::Color::WHITE)
      @time_font.draw("Time: #{@counter}", 20, 40, 3, 1, 1, Gosu::Color::WHITE)
      @xy_font.draw("x: #{@dan.x}, y: #{@dan.y}",20, 60, 3, 1, 1, Gosu::Color::WHITE)
    end
  end

  def button_down(id)
    case id
    when Gosu::KB_ESCAPE
      close
    when Gosu::KB_UP
      @dan.try_to_jump
    when Gosu::KB_RETURN
      if @current_view == @start_screen || @current_view == @game_over_screen
        @current_view = @sky
      end
    when Gosu::KB_SPACE
      if @dan.near_hatchdoor?
        @current_view = @moonshine_operation
        @dan.x = 500
        @dan.y = 100
        @map = Map.new("../assets/fixtures/moonshine_map.txt")
      end
    when Gosu::KB_DOWN
      @dan.x = @hatchdoor.x
      @dan.y = 400
    when Gosu::KB_W
      if @current_view == @moonshine_operation
        @current_view = @you_win_screen
      end
    else
      super
    end
  end

end

CowboyDan.new.show if __FILE__ == $0