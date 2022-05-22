require './Grid'

puts 'Welcome to Blackbox... enter difficulty (1-3)'
difficulty = gets
gridSize = 5

if difficulty.to_i == 1
    gridSize = 3
elsif difficulty.to_i == 2
    gridSize = 4
elsif difficulty.to_i == 3
    gridSize = 5
end

trinketsAmount = (gridSize*2).floor()

myGrid = Grid.new(gridSize)
myGrid.fillWithTrinkets(trinketsAmount)
myGrid.printGrid()
myGrid.getInput
