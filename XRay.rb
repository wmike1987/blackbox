require './Vector'
require './RightMirror'
require './LeftMirror'
require './Absorber'
require './Pillar'

class XRay < Light
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
        @startChar = 'x'
        @endChar = 'e'
        @evenChar = 'e'
        @oddChar = 'o'
        @possibleTrinketActors = Array.new
        @possibleTrinketActors.push(RightMirror, LeftMirror, Absorber)
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
        result = @possibleTrinketActors.include?(trinket.class)
        if(trinket.class == RightMirror || trinket.class == LeftMirror)
            @possibleTrinketActors.delete(RightMirror)
            @possibleTrinketActors.delete(LeftMirror)
        end
        return result
    end

    def absorberInteraction
        if @endChar == 'e'
            @endChar = 'o'
        else
            @endChar = 'e'
        end
    end
end
