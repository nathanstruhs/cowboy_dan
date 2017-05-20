require 'gosu'
require_relative 'map'
require_relative 'player'
require_relative 'wild_dog'


WIDTH, HEIGHT = 1000, 610

module Tiles
  Grass = 0
  Earth = 1
  Cacti = 2
end

class CowboyDan < Gosu::Window

  def initialize
    super WIDTH, HEIGHT
    self.caption = "Cowboy Dan"
    @sky = Gosu::Image.new("../assets/images/backgrounds/sky.jpg")
    @start_screen = Gosu::Image.new("../assets/images/backgrounds/start_screen.jpg")
    @game_over_screen = Gosu::Image.new("../assets/images/backgrounds/game_over.jpg")
    @current_view = @start_screen
    @map = Map.new("../assets/fixtures/map.txt")
    @camera_x = @camera_y = 0
    @soundtrack = Gosu::Song.new "../assets/fixtures/soundtrack.mp3"
    @game_over_soundtrack = Gosu::Song.new "../assets/fixtures/game_over.mp3"
    @soundtrack.play(looping = true)
    @wild_dog = WildDog.new 800, 450
    @dan = Player.new @map, 50, 600, @wild_dog
    @move_dog_x = 1
    @font = Gosu::Font.new(20)
    @counter = 0
  end

  def reset
    @current_view = @game_over_screen
    @camera_x = @camera_y = 0
    @wild_dog = WildDog.new 800, 450
    @dan = Player.new @map, 50, 600, @wild_dog
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
    @wild_dog.update(@move_dog_x)
    @dan.doggy_collision
    @dan.is_just_resting(@counter)
    if @dan.health.zero?
      reset
    end
    if @current_view == @sky
      @game_over_soundtrack.stop
      @soundtrack.play(looping = true)
    end
  end

  def draw
    if @current_view == @start_screen
      @start_screen.draw 0, 0, 0
    elsif @current_view == @game_over_screen
      @game_over_screen.draw 0, 0, 0
    else 
      @sky.draw 0, 0, 0
      Gosu.translate(-@camera_x, -@camera_y) do
        @map.draw
        @dan.draw
        @wild_dog.draw
      end
      @font.draw("Health: #{@dan.health}", 20, 10, 3, 1, 1, Gosu::Color::WHITE)
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
    else
      super
    end
  end

end

CowboyDan.new.show if __FILE__ == $0