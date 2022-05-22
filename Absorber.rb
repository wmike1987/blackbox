require './Directions'
require './GridObject'

class Absorber < GridObject
    attr_accessor :displayChar

    def initialize(position)
        @displayChar = '@'
        super
    end

    def actUponLight(light, grid)
        light.diminish()
    end
end
