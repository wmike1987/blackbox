require './Directions'
require './GridTrinket'

class LightDebuggerTrinket < GridTrinket
    attr_accessor :displayChar

    def initialize(position)
        @displayChar = '.'
        super
    end

    def actUponLight(light, grid)

    end
end
