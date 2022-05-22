require './Directions'
require './GridObject'

class NoopTrinket < GridObject
    attr_accessor :displayChar

    def initialize(position)
        @displayChar = ' '
        super
    end

    def actUponLight(light, grid)

    end
end
