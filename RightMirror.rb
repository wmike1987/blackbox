require './Directions'
require './GridTrinket'

class RightMirror < GridTrinket
    def initialize(position)
        super
    end

    def self.initializeDifficulty(difficulty)
        @@maxNumber = 99999
        @@minNumber = 1
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

    def self.displayChar
        return '/'
    end

    def self.maxNumber=(val)
        @@maxNumber = val
    end

    def self.maxNumber
        return @@maxNumber
    end

    def self.minNumber
        return @@minNumber
    end
end
