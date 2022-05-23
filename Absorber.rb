require './Directions'
require './GridTrinket'

class Absorber < GridTrinket
    def initialize(position)
        super
    end

    def self.initializeDifficulty(difficulty)
        @@maxNumber = 3 #always 3
        @@minNumber = 1
    end

    def actUponLight(light, grid)
        light.diminish()
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
