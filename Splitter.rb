require './Directions'
require './GridTrinket'

class Splitter < GridTrinket
    def initialize(position)
        super
    end

    def self.initializeDifficulty(difficulty)
        @@maxNumber = difficulty.to_i-1
    end

    def actUponLight(light, grid)
        light.diminish()
    end

    def self.displayChar
        return '%'
    end

    def self.maxNumber=(val)
        @@maxNumber = val
    end

    def self.maxNumber
        return @@maxNumber
    end
end
