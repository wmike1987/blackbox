require './Directions'
require './GridObject'

class RightMirror < GridObject
    attr_accessor :displayChar

    def initialize(position)
        @displayChar = '/'
        super
    end

    def actUponLight(light, grid)
        if light.direction == Directions.SOUTH
            light.direction = Directions.WEST
        elsif light.direction == Directions.NORTH
            light.direction = Directions.EAST
        elsif light.direction == Directions.EAST
            light.direction = Directions.NORTH
        elsif light.direction == Directions.WEST
            light.direction = Directions.SOUTH
        end
    end
end
