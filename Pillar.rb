require './Directions'
require './GridTrinket'

class Pillar < GridTrinket
    def initialize(position)
        super
    end

    def self.initializeDifficulty(difficulty)
        @@maxNumber = 1
        @@minNumber = 1
    end

    def actUponLight(light, grid)
        light.hitPillar()
    end

    def self.displayChar
        return 'O'
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
