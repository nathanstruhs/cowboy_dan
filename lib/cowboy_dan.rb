require 'gosu'
require_relative 'map'
require_relative 'player'
require_relative 'wild_dog'
require_relative 'bear'
require_relative 'cacti'
require_relative 'hatchdoor'


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
    @dialogue_box = Gosu::Image.new("../assets/images/sprites/dialogue.png")
    @dialogue_box_small = Gosu::Image.new("../assets/images/sprites/dialogue-small.png")
    @map = Map.new("../assets/fixtures/map.txt")
    @soundtrack = Gosu::Song.new "../assets/fixtures/soundtrack.mp3"
    @game_over_soundtrack = Gosu::Song.new "../assets/fixtures/game_over.mp3"
    @font = Gosu::Font.new(20, :name => "/Library/Fonts/AmericanTypewriter.ttc")
    @hud_display_font = Gosu::Font.new(40, :name => "/Library/Fonts/AmericanTypewriter.ttc")

    @current_view = @start_screen
    @camera_x = @camera_y = 0
    @soundtrack.play(looping = true)
    @wild_dogs = [(WildDog.new 800, 450)]
    @cacti = [(Cacti.new(100, 545))]
    @bear = Bear.new(300, 590)
    @hatchdoor = Hatchdoor.new(500, 552)
    @dan = Player.new(@map, 50, 600, @wild_dogs, @bear, @cacti, @hatchdoor)
    @move_dog_x = 1
    @counter = 0
  end

  def reset
    @current_view = @game_over_screen
    @camera_x = @camera_y = 0
    @wild_dogs = [(WildDog.new 800, 450)]
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
  end

  def draw
    if @dan.near_bear?
      @dialogue_box.draw(320, 245, 1)
      @font.draw("Howdy Dan! Careful 'round",     360, 280, 3, 1, 1, Gosu::Color::BLACK)
      @font.draw("these parts. Theres wild",      360, 300, 3, 1, 1, Gosu::Color::BLACK)
      @font.draw("dogs and killer cacti about.",  360, 320, 3, 1, 1, Gosu::Color::BLACK)
      @font.draw("Oh! and I also heard",          360, 340, 3, 1, 1, Gosu::Color::BLACK)
      @font.draw("of a secret moonshine",         360, 360, 3, 1, 1, Gosu::Color::BLACK)
      @font.draw("operation, keep yer",           360, 380, 3, 1, 1, Gosu::Color::BLACK)
      @font.draw("eyes open fer it!",             360, 400, 3, 1, 1, Gosu::Color::BLACK)
    end

    if @dan.near_hatchdoor?
      @dialogue_box_small.draw(@dan.x + 20, @dan.y - 240, 1)
      @font.draw("What in tarnation", @dan.x + 50, @dan.y - 220, 3, 1, 1, Gosu::Color::BLACK)
      @font.draw("is that smell? ", @dan.x + 50, @dan.y - 200, 3, 1, 1, Gosu::Color::BLACK)
      @font.draw("\"Hit the space bar", @dan.x + 50, @dan.y - 180, 3, 1, 1, Gosu::Color::BLACK)
      @font.draw("to check it out\"", @dan.x + 50, @dan.y - 160, 3, 1, 1, Gosu::Color::BLACK)
    end

    if @current_view == @start_screen
      @start_screen.draw(0, 0, 0)
    elsif @current_view == @game_over_screen
      @game_over_screen.draw(0, 0, 0)
    else
      if @current_view == @moonshine_operation
        @moonshine_operation.draw(0, 0, -1)
        @dan.draw
        @map.draw
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
      @current_view = @moonshine_operation
      @dan.x = 500
      @dan.y = 100
      @map = Map.new("../assets/fixtures/moonshine_map.txt")
    else
      super
    end
  end

end

CowboyDan.new.show if __FILE__ == $0