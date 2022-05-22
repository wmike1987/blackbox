require './Directions'
require './GridObject'

class LightDebuggerTrinket < GridObject
    attr_accessor :displayChar

    def initialize(position)
        @displayChar = '.'
        super
    end

    def actUponLight(light, grid)

    end
end
