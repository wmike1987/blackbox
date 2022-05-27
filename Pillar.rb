require './Directions'
require './GridTrinket'

class Pillar < GridTrinket
    def initialize(position)
        super
    end

    def self.initializeDifficulty(difficulty)
        @@maxNumber = difficulty.to_i + 1
        @@minNumber = 1
    end

    def actUponLight(light, grid)
        light.hitPillar()
    end

    def self.displayChar
        return 'P'
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
