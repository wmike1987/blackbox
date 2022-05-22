require './Vector'

class Directions
    @@NORTH = Vector.new(0, -1)
    @@SOUTH = Vector.new(0, 1)
    @@EAST = Vector.new(1, 0)
    @@WEST = Vector.new(-1, 0)

    def self.NORTH
        @@NORTH
    end

    def self.SOUTH
        @@SOUTH
    end

    def self.EAST
        @@EAST
    end

    def self.WEST
        @@WEST
    end
end
