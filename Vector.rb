class Vector
    attr_accessor :x
    attr_accessor :y

    def initialize(x, y)
        @x = x
        @y = y
    end

    def clone()
        return Vector.new(self.x, self.y)
    end
end
