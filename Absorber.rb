require './Directions'
require './GridTrinket'

class Absorber < GridTrinket
    def initialize(position)
        super
    end

    def self.initializeDifficulty(difficulty)
        @@maxNumber = difficulty.to_i+3
        @@minNumber = 3
    end

    def actUponLight(light, grid)
        light.absorberInteraction()
    end

    def self.displayChar
        return '@'
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
