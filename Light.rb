require './Vector'

class Light
    attr_accessor :direction
    attr_accessor :startingPosition
    attr_accessor :endingPosition
    attr_accessor :currentPosition
    attr_accessor :finished
    attr_accessor :power
    attr_accessor :startChar
    attr_accessor :endChar


    def initialize(direction, position, grid)
        @direction = direction
        @startingPosition = position.clone()
        @currentPosition = position.clone()
        @endingPosition = nil
        @finished = false
        @grid = grid
        @power = 3
        @startChar = '*'
        @endChar = '!'
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

    def diminish
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
