require './RightMirror'
require './LeftMirror'
require './Absorber'
require './NoopTrinket'
require './LightDebuggerTrinket'
require './Vector'
require './Directions'
require './Light'

class Grid
    attr_accessor :gridSize
    attr_accessor :originalGridSize
    attr_accessor :grid
    attr_accessor :light
    attr_accessor :trinketList
    attr_accessor :addedTrinkets
    attr_accessor :absorbersAdded

    def initialize(size)
        @originalGridSize = size
        @gridSize = size + 2 #buffer for input/outputs
        @grid = Array.new(@gridSize) { Array.new(@gridSize) }
        @trinketList = Array.new()
        @trinketList.push(RightMirror, LeftMirror)
        @addedTrinkets = Array.new()
        @absorbersAdded = 0
        @maxAbsorbers = 3
        @fullInfo = false
    end

    def addTrinket(trinket)
        @addedTrinkets.push(trinket)
        @grid[trinket.position.x][trinket.position.y] = trinket
    end

    def displayTrinkets
        trinketDict = {}
        @addedTrinkets.each do |tr|
            if tr.is_a?(NoopTrinket)
                next
            end
            if trinketDict[tr.displayChar] == nil
                trinketDict[tr.displayChar] = 1
            else
                trinketDict[tr.displayChar] += 1
            end
        end

        trinketDict.each do |key, value|
            puts "#{key} x #{value}"
        end
    end

    def getEmptyGridLocation
        x = nil
        y = nil
        loop do
            x = rand(0..@originalGridSize-1)
            y = rand(0..@originalGridSize-1)
            break if @grid[x][y] == nil
        end
        return Vector.new(x, y)
    end

    def fillWithTrinkets(amount)
        for i in 0...amount
            position = getEmptyGridLocation()
            newTrinket = nil
            if(@absorbersAdded != @maxAbsorbers)
                newTrinket = Absorber.new(position)
                @absorbersAdded += 1
            else
                newTrinket = @trinketList.sample().new(position)
            end
            addTrinket(newTrinket)
        end

        for i in 0..@originalGridSize-1
            for j in 0..@originalGridSize-1
                if @grid[i][j] == nil
                    addTrinket(NoopTrinket.new(Vector.new(i, j)))
                end
            end
        end
    end

    def getTrinketAtPosition(position)
        @grid[position.x][position.y]
    end

    def getInput
        puts ''
        puts 'Enter light position...'
        xPos = gets.chomp()
        parsedPosition = nil
        lightDirection = nil

        normalEntrance = xPos.length == 1
        oppositeEntrance = xPos.length == 2

        if xPos == "show"
            @fullInfo = !@fullInfo
            printGrid()
            getInput()
            return nil
        end

        if xPos == "goal"
            displayTrinkets()
            getInput()
            return nil
        end

        if normalEntrance
            if xPos.to_i > 0
                parsedPosition = Vector.new(-1, (@originalGridSize-xPos.to_i).abs())
                lightDirection = Directions.EAST
            else
                parsedPosition = Vector.new(((xPos.ord-97)), @originalGridSize)
                lightDirection = Directions.NORTH
            end
        elsif oppositeEntrance
            if xPos[0].to_i > 0
                parsedPosition = Vector.new(@originalGridSize, (@originalGridSize-xPos[0].to_i).abs())
                lightDirection = Directions.WEST
            else
                parsedPosition = Vector.new(((xPos.ord-97)).abs(), -1)
                lightDirection = Directions.SOUTH
            end
        end

        if parsedPosition.x > @originalGridSize + 1 || parsedPosition.x < -1
            puts 'invalid position'
            getInput()
            return nil
        end

        if parsedPosition.y > @originalGridSize + 1 || parsedPosition.y < -1
            puts 'invalid position'
            getInput()
            return nil
        end

        @light = Light.new(lightDirection, parsedPosition, self)
        runLight()
        printGrid()
        getInput()
    end

    def runLight
        loop do
            @light.advance()
            trinket = getTrinketAtPosition(@light.currentPosition)

            if trinket != nil
                trinket.actUponLight(@light, self)
            end
            if @light.finished
                break
            end
        end
    end

    def printGrid()
        system("clear") || system("cls")
        withTrinkets = @fullInfo
        leftBuffer = '   '
        smallLeftBuffer = '  '
        inputOutputBuffer = 2
        trinketGridSize = @originalGridSize
        fullIterationLength = (trinketGridSize * 2) + 1 + inputOutputBuffer
        for i in 0...fullIterationLength
            puts ''
            borderRow = i % 2 != 0
            realRow = i % 2 == 0

            #handle light input output
            if i == 0 || i == fullIterationLength-1
                for j in 0...fullIterationLength
                    if j == 0 || j == fullIterationLength-1
                        next
                    end
                    realCol = j % 2 == 0
                    borderCol = j % 2 != 0

                    realGridLocationY = (i-1)/2
                    realGridLocationX = (j-1)/2

                    lightCharacter = '   '

                    if @light != nil
                        if @light.startingPosition.x == realGridLocationX && @light.startingPosition.y == realGridLocationY
                            lightCharacter = ' ' + @light.startChar + ' '
                        end

                        if @light.endingPosition.x == realGridLocationX && @light.endingPosition.y == realGridLocationY
                            lightCharacter = ' ' + @light.endChar + ' '
                        end
                    end

                    if realCol
                        charToPrint = lightCharacter
                    elsif borderCol
                        charToPrint = ' '
                    end
                    if j == 1
                        charToPrint = leftBuffer + charToPrint
                    end
                    print charToPrint
                end
                next
            end

            if borderRow
                for j in 0...fullIterationLength
                    if j == 0 || j == fullIterationLength-1
                        next
                    end
                    borderCol = j % 2 != 0

                    if borderCol
                        charToPrint = '+'
                    else
                        charToPrint = '---'
                    end

                    if j == 1
                        charToPrint = leftBuffer + charToPrint
                    end

                    print charToPrint
                end
            elsif realRow
                for j in 0...fullIterationLength
                    #handle light input output

                    realGridLocationY = (i-1)/2
                    realGridLocationX = (j-1)/2

                    lightCharacter = '   '

                    if @light != nil
                        if @light.startingPosition.x == realGridLocationX && @light.startingPosition.y == realGridLocationY
                            lightCharacter = ' ' + @light.startChar + ' '
                        end

                        if @light.endingPosition.x == realGridLocationX && @light.endingPosition.y == realGridLocationY
                            lightCharacter = ' ' + @light.endChar + ' '
                        end
                    end

                    if j == 0 || j == fullIterationLength-1
                        if j == 0
                            charToPrint = lightCharacter
                        end

                        if j == fullIterationLength-1
                            charToPrint = lightCharacter
                        end
                        print charToPrint
                        next
                    end

                    borderCol = j % 2 != 0
                    if borderCol
                        charToPrint = '|'
                    elsif
                        realGridLocationX = (j-1)/2
                        realGridLocationY = (i-1)/2
                        trinketChar = ' '
                        trinket = @grid[realGridLocationX][realGridLocationY]
                        if trinket != nil && withTrinkets
                            trinketChar = trinket.displayChar
                        end
                        charToPrint = ' ' + trinketChar + ' '
                    end

                    print charToPrint
                end
            end
        end
        puts ''
    end
end
