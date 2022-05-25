require './RightMirror'
require './LeftMirror'
require './Absorber'
require './Pillar'
require './Splitter'
require './NoopTrinket'
require './Vector'
require './Directions'
require './Light'
require './Sonar'
require './BlueLight'

class Grid
    attr_accessor :gridSize
    attr_accessor :originalGridSize
    attr_accessor :grid
    attr_accessor :lights
    attr_accessor :lightMode
    attr_accessor :availableTrinkets
    attr_accessor :trinketCount

    def initialize(size, difficulty)
        #init grid vars
        @difficulty = difficulty
        @originalGridSize = size
        @gridSize = size + 2 #buffer for input/outputs
        @grid = Array.new(@gridSize) { Array.new(@gridSize) }
        @gridRevealed = false
        @lights = Array.new
        @lightMode = Light
        @lightTypes = Array.new()
        @lightTypes.push(Light, Sonar, BlueLight)

        #create trinket list and other trinket vars
        @availableTrinkets = Array.new()
        @availableTrinkets.push(RightMirror, LeftMirror, Absorber, Pillar)
        @availableTrinkets.each do |tr|
            tr.initializeDifficulty(@difficulty)
        end

        #establish min trinkets
        @minTrinkets = Array.new()
        @availableTrinkets.each do |tr|
            for i in 0...tr.minNumber
                @minTrinkets.push(tr)
            end
        end
        @trinketCount = {}
    end

    def addTrinket(trinket)
        if @trinketCount[trinket.class.displayChar] == nil
            @trinketCount[trinket.class.displayChar] = 1
        else
            @trinketCount[trinket.class.displayChar] += 1
        end

        @grid[trinket.position.x][trinket.position.y] = trinket
    end

    def addLight(position, direction, power=3, lightClass)
        newLight = lightClass.new(position, direction, power, self)
        @lights.push(newLight)
    end

    def clearLights
        @lights = Array.new
    end

    def displayGoal
        @trinketCount.each do |key, value|
            if key != ' '
                puts "#{key} x #{value}"
            end
        end
    end

    def getGoal
        trinketStrings = Array.new
        @trinketCount.each do |key, value|
            if key != ' '
                trinketStrings.push("#{key} x #{value}")
            end
        end
        return trinketStrings
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

            loop do
                if @minTrinkets.length > 0
                    chosenTrinket = @minTrinkets.shift()
                else
                    chosenTrinket = @availableTrinkets.sample()
                end
                currentTrinketCount = @trinketCount[chosenTrinket.displayChar]
                if currentTrinketCount == nil
                    currentTrinketCount = 0
                end

                if currentTrinketCount < chosenTrinket.maxNumber
                    addTrinket(chosenTrinket.new(position))
                    break
                end
            end
        end

        #fill other spaces with noop trinkets, this allows us to avoid
        #doing nil checks when retreiving a trinket from a position
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

    def exitHelp
        puts 'Press \'Enter\' to return to the blackbox...'
        whatever = gets.chomp()
        printGrid()
        getInput()
    end

    def getNextLightType
        if @lightMode == @lightTypes[-1]
            @lightMode = @lightTypes[0]
        else
            currentIndex = @lightTypes.index(@lightMode)
            @lightMode = @lightTypes[currentIndex+1]
        end
    end

    def getInput
        begin
            puts ''
            if @lightMode == Light
                puts 'Laser mode... enter position'
            elsif @lightMode == Sonar
                puts 'Sonar mode... enter position'
            elsif @lightMode == BlueLight
                puts 'Blue-ray mode... enter position'
            end

            xPos = gets.chomp()
            parsedPosition = nil
            lightDirection = nil

            if xPos == 'exit'
                return nil
            end

            if xPos == ''
                getNextLightType()
                if @lights[0] != nil
                    currentLight = @lights[0]
                    clearLights()
                    addLight(currentLight.startingPosition, currentLight.originalDirection, 3, @lightMode)
                    runLights()
                end
                printGrid()
                getInput()
                return nil
            end

            normalEntrance = xPos.length == 1
            oppositeEntrance = xPos.length == 2

            if xPos == 'help'
                puts ''
                puts '---How to play---'
                puts 'Enter a, b, 1, 2, etc to start a laser at that position.'
                puts 'Double the position (aa, bb, 11, 22, etc) to shoot a laser from the opposite side.'
                puts ''
                puts '---Commands---'
                puts 'Type blank \'\' to switch laser types.'
                puts 'Type \'reveal\' to toggle the answer.'
                puts 'Type \'exit\' to return to the starting screen.'
                puts ''
                puts '---Lasers---'
                puts 'White-light: (*) -> (!, :, .)'
                puts '• Reflects off all mirrors.'
                puts '• Loses power upon hitting an absorber.'
                puts '  - Hitting 1 absorber produces \':\' as the output.'
                puts '  - Hitting 2 absorbers produces \'.\' as the output.'
                puts '  - Hitting 3 absorbers kills the laser. (no output)'
                puts '• Full power (!) cannot pass through pillars.'
                puts '• Lesser powers, (:) and (.), can pass through pillars.'
                puts ''
                puts 'Blue-light: (+) -> ()'
                puts '• Passes through pillars.'
                puts '• Passes through mirrors.'
                puts '• Spawns two white lasers perpendicular to current direction for every absorber it encounters.'
                puts '• Produces no output of its own.'
                puts ''
                puts 'Sonar: (#) -> (e, o)'
                puts '• Passes through pillars.'
                puts '• Output character indicates if it encounters an even or odd amount of absorbers (e or o).'
                puts '• Starting character indicates difference in trinkets vs empty spaces encountered (absolute value).'
                puts '• Reflects off only the first mirror it encounters.'
                puts ''
                puts '---Trinkets---'
                puts '/ - right mirror'
                puts '\ - left mirror'
                puts '@ - absorber'
                puts 'O - pillar'
                puts ''

                exitHelp()
                return nil
            end

            if xPos == "reveal"
                @gridRevealed = !@gridRevealed
                printGrid()
                getInput()
                return nil
            end

            if normalEntrance
                if xPos.to_i > 0
                    if xPos.to_i > @originalGridSize || xPos.to_i < 1
                        raise "input exception"
                    end
                    parsedPosition = Vector.new(-1, (@originalGridSize-xPos.to_i).abs())
                    lightDirection = Directions.EAST
                else
                    if xPos.ord-97+1 > @originalGridSize || xPos.ord-97+1 < 1
                        raise "input exception"
                    end
                    parsedPosition = Vector.new(((xPos.ord-97)), @originalGridSize)
                    lightDirection = Directions.NORTH
                end
            elsif oppositeEntrance
                if xPos[0].to_i > 0
                    if xPos[0].to_i > @originalGridSize || xPos[0].to_i < 1
                        raise "input exception"
                    end
                    parsedPosition = Vector.new(@originalGridSize, (@originalGridSize-xPos[0].to_i).abs())
                    lightDirection = Directions.WEST
                else
                    if (xPos[0].ord-97 + 1).abs() > @originalGridSize || (xPos[0].ord-97 + 1).abs() < 1
                        raise "input exception"
                    end
                    parsedPosition = Vector.new(((xPos[0].ord-97)).abs(), -1)
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

            clearLights()
            addLight(parsedPosition, lightDirection, 3, @lightMode)
            runLights()
            printGrid()
            getInput()
        rescue
            puts 'invalid input'
            getInput()
        end
    end

    def runLights
        loop do
            @lights.each do |light|
                light.advance()
                trinket = getTrinketAtPosition(light.currentPosition)
                if trinket != nil
                    if light.trinketCanActUponMe(trinket)
                        trinket.actUponLight(light, self)
                    end
                end
            end

            canBreak = true
            @lights.each do |light|
                if !light.finished
                    canBreak = false
                end
            end
            if canBreak
                break
            end
        end
    end

    def aLightStartedAtPosition(position)
        foundLight = nil
        @lights.each do |light|
            if light.startingPosition.equals(position)
                foundLight = light
            end
        end

        return foundLight
    end

    def aLightEndedAtPosition(position)
        foundLight = nil
        @lights.each do |light|
            if light.endingPosition.equals(position)
                foundLight = light
            end
        end

        return foundLight
    end

    def printGrid()
        system("clear") || system("cls")
        withTrinkets = @gridRevealed
        trinketGoal = getGoal()
        leftBuffer = '  '
        leftBufferLabel = '  '
        inputOutputBuffer = 2
        trinketGridSize = @originalGridSize
        fullIterationLength = (trinketGridSize * 2) + 1 + inputOutputBuffer
        for i in 0...fullIterationLength
            puts ''
            borderRow = i % 2 != 0
            realRow = i % 2 == 0
            rowNumberLabel = (@originalGridSize - (i-1)/2).to_s

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

                    startLight = aLightStartedAtPosition(Vector.new(realGridLocationX, realGridLocationY))
                    endLight = aLightEndedAtPosition(Vector.new(realGridLocationX, realGridLocationY))
                    if startLight != nil
                        lightCharacter = ' ' + startLight.getStartChar + ' '
                    end

                    if endLight != nil
                        lightCharacter = ' ' + endLight.endChar + ' '
                    end

                    if realCol
                        charToPrint = lightCharacter
                    elsif borderCol
                        charToPrint = ' '
                    end
                    if j == 1
                        charToPrint = leftBuffer + leftBufferLabel + charToPrint
                    end
                    print charToPrint
                end
                next
            end

            if borderRow
                for j in 0...fullIterationLength
                    if j == 0 || j == fullIterationLength-1
                        if j == fullIterationLength-1
                            print '      ' + (trinketGoal.shift() || '')
                        end
                        next
                    end
                    borderCol = j % 2 != 0

                    if borderCol
                        charToPrint = '+'
                    else
                        charToPrint = '---'
                    end

                    if j == 1
                        charToPrint = leftBuffer + leftBufferLabel + charToPrint
                    end

                    print charToPrint
                end
            elsif realRow
                for j in 0...fullIterationLength
                    #handle light input output

                    realGridLocationY = (i-1)/2
                    realGridLocationX = (j-1)/2

                    labelCharacter = ' '
                    realRowBuffer = ' '
                    lightCharacter = ' '
                    compoundedLabel = '   '
                    lightBuffer = ' '

                    if j == 0
                        labelCharacter = rowNumberLabel
                    else
                        labelCharacter = ''
                    end

                    startLight = aLightStartedAtPosition(Vector.new(realGridLocationX, realGridLocationY))
                    endLight = aLightEndedAtPosition(Vector.new(realGridLocationX, realGridLocationY))
                    if startLight != nil
                        lightCharacter = startLight.getStartChar
                    end

                    if endLight != nil
                        lightCharacter = endLight.endChar
                    end

                    compoundedLabel = labelCharacter + realRowBuffer + lightCharacter + lightBuffer

                    if j == 0 || j == fullIterationLength-1
                        if j == 0
                            charToPrint = compoundedLabel
                        end

                        if j == fullIterationLength-1
                            charToPrint = compoundedLabel + '   ' + (trinketGoal.shift() || '')
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
                            trinketChar = trinket.class.displayChar
                        end
                        charToPrint = ' ' + trinketChar + ' '
                    end

                    print charToPrint
                end
            end
        end
        puts ''
        xAxisLabel = ''
        for j in 0...fullIterationLength
            realCol = j % 2 == 0
            borderCol = j % 2 != 0
            if j == 0 || j == fullIterationLength-1
                next
            end

            if realCol
                labelCharacter = (((j-1)/2) + 97).chr
                xAxisLabel += '  ' + labelCharacter + ' '
            end
        end
        puts leftBuffer + leftBufferLabel + xAxisLabel
    end
end
