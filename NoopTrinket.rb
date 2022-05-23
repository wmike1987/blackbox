require './Directions'
require './GridTrinket'

class NoopTrinket < GridTrinket
    def initialize(position)
        super
    end

    def actUponLight(light, grid)

    end

    def self.displayChar
        return ' '
    end
end
