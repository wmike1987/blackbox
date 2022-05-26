require './Grid'

while true
    puts 'Welcome to blackbox... enter difficulty (1-3)'
    difficulty = gets
    gridSize = difficulty.to_i + 2
    trinketsAmount = (gridSize*gridSize*2/3).floor()

    myGrid = Grid.new(gridSize, difficulty)
    myGrid.fillWithTrinkets(trinketsAmount)
    myGrid.printGrid()
    myGrid.getInput
end
