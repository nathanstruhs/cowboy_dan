class Map
  attr_reader :width, :height

  def initialize file
    @tile_set = Gosu::Image.load_tiles("../assets/images/backgrounds/tile-set-2.png", 60, 60, :tileable => true)
    lines = File.readlines(file).map { |line| line.chomp }
    @height = lines.size
    @width = lines[0].size
    @tiles = Array.new(@width) do |x|
      Array.new(@height) do |y|
        case lines[y][x,1]
        when '"'
          Tiles::Grass
        when '#'
          Tiles::Earth
        else
          nil
        end
      end
    end
  end

  def draw
    @height.times do |y|
      @width.times do |x|
        tile = @tiles[x][y]
        if tile
          @tile_set[tile].draw(x * 50 - 5, y * 50 - 5, 50)
        end
      end
    end
  end

  def solid?(x, y)
    y < 0 || @tiles[x / 50][y / 50]
  end

  def reset
    @tiles.clear
  end

end