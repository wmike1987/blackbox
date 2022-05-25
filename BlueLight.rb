require './Vector'
require './RightMirror'
require './LeftMirror'
require './Absorber'
require './Pillar'
require './Light'
require './Directions'

class BlueLight < Light
    attr_accessor :direction
    attr_accessor :startingPosition
    attr_accessor :endingPosition
    attr_accessor :currentPosition
    attr_accessor :finished
    attr_accessor :power
    attr_accessor :startChar
    attr_accessor :endChar


    def initialize(position, direction, power, grid)
        super(position, direction, power, grid)
    end

    def initLightSpecificAttrs(position, direction, power, grid)
        @startChar = 'B'
        @endChar = ' '
        @possibleTrinketActors = Array.new
        @possibleTrinketActors.push(Absorber)
    end

    def finish
        @finished = true
        @endingPosition = @currentPosition.clone()
    end

    def advance
        if @finished
            return nil
        end

        @currentPosition.x += direction.x
        @currentPosition.y += direction.y

        if @currentPosition.x > @grid.originalGridSize-1 || @currentPosition.x < 0
            finish()
        end

        if @currentPosition.y > @grid.originalGridSize-1 || @currentPosition.y < 0
            finish()
        end
    end

    def trinketCanActUponMe(trinket)
        return @possibleTrinketActors.include?(trinket.class)
    end

    def absorberInteraction
        # finish()

        direction1 = nil
        direction2 = nil
        if @direction == Directions.NORTH || @direction == Directions.SOUTH
            direction1 = Directions.EAST
            direction2 = Directions.WEST
        else
            direction1 = Directions.NORTH
            direction2 = Directions.SOUTH
        end

        @grid.addLight(@currentPosition, direction1, 3, Light)
        @grid.addLight(@currentPosition, direction2, 3, Light)
        @grid.runLights()
        @grid.printGrid()
    end
end
