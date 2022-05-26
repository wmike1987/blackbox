require './Vector'
require './RightMirror'
require './LeftMirror'
require './Absorber'
require './Pillar'

class Light
    attr_accessor :direction
    attr_accessor :startingPosition
    attr_accessor :originalDirection
    attr_accessor :endingPosition
    attr_accessor :currentPosition
    attr_accessor :finished
    attr_accessor :power
    attr_accessor :startChar
    attr_accessor :endChar


    def initialize(position, direction, power, grid)
        @startingPosition = position.clone()
        @currentPosition = position.clone()
        @endingPosition = nil
        @originalDirection = direction
        @direction = direction
        @power = power
        @grid = grid
        @finished = false
        initLightSpecificAttrs(position, direction, power, grid)
    end

    def initLightSpecificAttrs(position, direction, power, grid)
        @startChar = '*'
        @endChar = '!'
    end

    def finish
        @finished = true
        @endingPosition = @currentPosition.clone()
    end

    def hitPillar
        if @power == 3
            finish()
        end
    end

    def getStartChar
        return @startChar
    end

    def advance
        if @finished
            return nil
        end

        @currentPosition.x += direction.x
        @currentPosition.y += direction.y

        if @currentPosition.x > @grid.gridSize-1 || @currentPosition.x < 0
            finish()
        end

        if @currentPosition.y > @grid.gridSize-1 || @currentPosition.y < 0
            finish()
        end
    end

    def trinketCanActUponMe(trinket)
        return true
    end

    def absorberInteraction
        @power -= 1
        if @power == 0
            finish()
        end

        if @power == 2
            @endChar = ':'
        end

        if @power == 1
            @endChar = '.'
        end
    end
end
