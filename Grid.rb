require './RightMirror'
require './LeftMirror'
require './Absorber'
require './Pillar'
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
    attr_accessor :seed

    def initialize(size, difficulty, seed=nil)
        #init grid vars
        @difficulty = difficulty
        @gridSize = size# + 2 #buffer for input/outputs
        @grid = Array.new(@gridSize) { Array.new(@gridSize) }
        @placedTrinkets = Array.new(@gridSize) { Array.new(@gridSize) }
        @placedTrinketCount = {}
        @strikes = 0
        @successfullyPlacedCount = 0
        @gridRevealed = false
        @lights = Array.new
        @lightMode = Light
        @lightTypes = Array.new()
        @lightTypes.push(Light, Sonar, BlueLight)
        @seed = seed != nil ? seed : (difficulty.to_s + rand(500000).to_s).to_i
        srand(@seed)

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

    def getTotalTrinkets
        totalAmount = 0
        @trinketCount.each do |key, value|
            if key == ' '
                next
            end
            totalAmount += value
        end

        return totalAmount
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
                placedTrinketCount = @placedTrinketCount[key] == nil ? (value) : (value - @placedTrinketCount[key])
                trinketStrings.push("#{key} x #{value} (" + placedTrinketCount.to_s + ' left)')
            end
        end
        return trinketStrings
    end

    def getEmptyGridLocation
        x = nil
        y = nil
        loop do
            x = rand(0..@gridSize-1)
            y = rand(0..@gridSize-1)
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
        for i in 0..@gridSize-1
            for j in 0..@gridSize-1
                if @grid[i][j] == nil
                    addTrinket(NoopTrinket.new(Vector.new(i, j)))
                end

                @placedTrinkets[i][j] = ' '

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

    def inputLoop
        loop do
            ret = getInput()
            if ret == 'win'
                break
            end
        end
    end

    def getInput(forcedInput=nil)
        begin
            puts ''
            if @lightMode == Light
                puts 'White light mode...'
            elsif @lightMode == Sonar
                puts 'Sonar mode...'
            elsif @lightMode == BlueLight
                puts 'Blue light mode...'
            end

            if forcedInput != nil
                userInput = forcedInput
            else
                userInput = gets.chomp()
            end

            parsedPosition = nil
            lightDirection = nil

            if userInput.start_with?('place')
                placedTrinket = userInput[6]
                placementCol = userInput[11]
                placementRow = userInput[12]

                #validate trinket input
                trinketCharValid = false
                @availableTrinkets.each do |trinket|
                    if placedTrinket == trinket.displayChar
                        trinketCharValid = true
                    end
                end

                if !trinketCharValid
                    puts 'invalid trinket'
                    return nil
                end

                #validate coordinate
                xCoordValid = true
                parsedCol = (placementCol.ord-97).abs()
                if parsedCol < 0 || parsedCol > @gridSize-1
                    xCoordValid = false
                end

                yCoordValid = true
                parsedRow = @gridSize-1-(placementRow.to_i-1)
                if parsedRow < 0 || parsedRow > @gridSize-1
                    yCoordValid = false
                end

                if !xCoordValid || !yCoordValid
                    puts 'invalid coordinate'
                    return nil
                end

                #win or lose
                currentTrinket = getTrinketAtPosition(Vector.new(parsedCol, parsedRow))
                if currentTrinket.class.displayChar != placedTrinket
                    @strikes += 1
                    if @strikes < 3
                        puts 'Incorrect, strike' + @strikes.to_s
                        return nil
                    else
                        @gridRevealed = true
                        printGrid()
                        puts 'Strike ' + @strikes.to_s + '. Game over...'
                        return 'lose'
                    end
                else
                    @placedTrinkets[parsedCol][parsedRow] = placedTrinket
                    if @placedTrinketCount[placedTrinket] == nil
                        @placedTrinketCount[placedTrinket] = 1
                    else
                        @placedTrinketCount[placedTrinket] += 1
                    end
                    @successfullyPlacedCount += 1
                end

                #redraw grid
                printGrid()
                if @successfullyPlacedCount >= getTotalTrinkets()
                    puts ''
                    puts 'You solved the blackbox with ' + @strikes.to_s  + ' strikes, congratulations.'
                    return 'win'
                else
                    puts ''
                    puts 'Correct!'
                end

                return nil
            end

            if userInput == 'exit'
                return nil
            end

            if userInput == ''
                getNextLightType()
                if @lights[0] != nil
                    currentLight = @lights[0]
                    clearLights()
                    addLight(currentLight.startingPosition, currentLight.originalDirection, 3, @lightMode)
                    runLights()
                end
                printGrid()
                return nil
            end

            normalEntrance = userInput.length == 1
            oppositeEntrance = userInput.length == 2

            if userInput == 'help' || userInput == 'h'
                puts ''
                puts '---How to play---'
                puts 'Enter a, b, 1, 2, etc to start a laser at that position.'
                puts 'Double the position (aa, bb, 11, 22, etc) to shoot a laser from the opposite side.'
                puts 'Correctly guess all trinkets to win the game (using the place command, below).'
                puts ''
                puts '---Commands---'
                puts 'Press Enter \'\' to switch laser types.'
                puts 'Type \'reveal\' to toggle the answer.'
                puts 'Type \'place @ at a3\' (for example), to guess as abosrber at coordinate a3.'
                puts 'Type \'exit\' to return to the starting screen.'
                puts ''
                puts '---Trinkets---'
                puts '/ - right mirror'
                puts '\ - left mirror'
                puts '@ - absorber'
                puts 'P - pillar'
                puts ''
                puts '---Lasers---'
                puts 'White-light: (*) -> (!, :, .)'
                puts '??? Reflects off all mirrors.'
                puts '??? Can only reflect off the same mirror twice. It will pass through'
                puts '  on subsequent encounters. Note: This is a rare case.'
                puts '??? Loses 1 power-level for every absorber encountered.'
                puts '  - Full power (!) -> Half power (:) -> Low power (.) -> No power (no output)'
                puts '??? Full power (!) cannot pass through pillars.'
                puts '??? Half power (:) dies and spawns two low-power (.) lights perpendicular to current'
                puts '  direction upon hitting a pillar.'
                puts '??? Low power (.) passes through pillars.'
                puts ''
                puts 'Blue-light: (B) -> ()'
                puts '??? Passes through pillars and mirrors.'
                puts '??? Dies and spawns two white lasers perpendicular to current direction upon'
                puts '  encountering an absorber.'
                puts '??? Produces no output of its own.'
                puts ''
                puts 'Sonar: (digit) -> (e, o)'
                puts '??? Passes through pillars.'
                puts '??? Output character indicates if it encounters an even or odd amount of absorbers (e or o).'
                puts '??? Starting character indicates difference in trinkets vs empty spaces encountered (absolute value).'
                puts '??? Reflects off only the first two mirrors encountered.'
                puts ''

                exitHelp()
                return nil
            end

            if userInput == "reveal" || userInput == "r"
                @gridRevealed = !@gridRevealed
                printGrid()
                return nil
            end

            if normalEntrance
                if userInput.to_i > 0
                    if userInput.to_i > @gridSize || userInput.to_i < 1
                        raise "input exception"
                    end
                    parsedPosition = Vector.new(-1, (@gridSize-userInput.to_i).abs())
                    lightDirection = Directions.EAST
                else
                    if userInput.ord-97+1 > @gridSize || userInput.ord-97+1 < 1
                        raise "input exception"
                    end
                    parsedPosition = Vector.new(((userInput.ord-97)), @gridSize)
                    lightDirection = Directions.NORTH
                end
            elsif oppositeEntrance
                if userInput[0].to_i > 0
                    if userInput[0].to_i > @gridSize || userInput[0].to_i < 1
                        raise "input exception"
                    end
                    parsedPosition = Vector.new(@gridSize, (@gridSize-userInput[0].to_i).abs())
                    lightDirection = Directions.WEST
                else
                    if (userInput[0].ord-97 + 1).abs() > @gridSize || (userInput[0].ord-97 + 1).abs() < 1
                        raise "input exception"
                    end
                    parsedPosition = Vector.new(((userInput[0].ord-97)).abs(), -1)
                    lightDirection = Directions.SOUTH
                end
            end

            if parsedPosition.x > @gridSize + 1 || parsedPosition.x < -1
                puts 'invalid position'
                return nil
            end

            if parsedPosition.y > @gridSize + 1 || parsedPosition.y < -1
                puts 'invalid position'
                return nil
            end

            clearLights()
            addLight(parsedPosition, lightDirection, 3, @lightMode)
            runLights()
            printGrid()
        rescue => exception
            puts 'invalid input'
            # puts exception.stacktrace
            return nil
        end
    end

    def runLights
        loop do
            @lights.each do |light|
                light.advance()
                if light.finished
                    next
                end
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
        puts 'puzzle id: ' + @seed.to_s
        withTrinkets = @gridRevealed
        trinketGoal = getGoal()
        leftScreenBuffer = ' '
        leftBuffer = '  '
        leftBufferLabel = '  '
        inputOutputBuffer = 2
        trinketGridSize = @gridSize
        fullIterationLength = (trinketGridSize * 2) + 1 + inputOutputBuffer
        for i in 0...fullIterationLength
            puts ''
            borderRow = i % 2 != 0
            realRow = i % 2 == 0
            rowNumberLabel = (@gridSize - (i-1)/2).to_s

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
                        charToPrint = leftScreenBuffer + leftBuffer + leftBufferLabel + charToPrint
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
                        charToPrint = leftScreenBuffer + leftBuffer + leftBufferLabel + charToPrint
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

                    leftCompoundedLabel = leftScreenBuffer + labelCharacter + realRowBuffer + lightCharacter + lightBuffer
                    rightCompoundedLabel = labelCharacter + realRowBuffer + lightCharacter + lightBuffer

                    if j == 0 || j == fullIterationLength-1
                        if j == 0
                            charToPrint = leftCompoundedLabel
                        end

                        if j == fullIterationLength-1
                            charToPrint = rightCompoundedLabel + '   ' + (trinketGoal.shift() || '')
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

                        placedTrinket = @placedTrinkets[realGridLocationX][realGridLocationY]

                        if placedTrinket
                            trinketChar = placedTrinket
                        end

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
        puts leftScreenBuffer + leftBuffer + leftBufferLabel + xAxisLabel
    end
end
