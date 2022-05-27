require './Grid'
require './Tester'

while true
    puts 'Welcome to blackbox...'
    puts 'Enter difficulty (1-5) or type \'id\' to enter a specific puzzle'

    difficulty = gets.chomp
    trinketPercentage = (0.6)

    if difficulty == 'test'
        Tester.new().runTest(4, 1000)
    elsif difficulty == 'id'
        puts 'Enter puzzle id'
        seed = gets.chomp.to_i

        difficulty = seed.to_s[0]

        gridSize = difficulty.to_i + 2
        trinketsAmount = (gridSize*gridSize*trinketPercentage).floor()

        myGrid = Grid.new(gridSize, difficulty, seed)
        myGrid.fillWithTrinkets(trinketsAmount)
        myGrid.printGrid()
        myGrid.inputLoop()
    else
        gridSize = difficulty.to_i + 2
        trinketsAmount = (gridSize*gridSize*trinketPercentage).floor()

        myGrid = Grid.new(gridSize, difficulty)
        myGrid.fillWithTrinkets(trinketsAmount)
        myGrid.printGrid()
        myGrid.inputLoop()
    end
end
