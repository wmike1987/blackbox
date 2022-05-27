require './Light'
require './Sonar'
require './BlueLight'

class Tester

    def spawnInput(grid)
        grid.getInput('a')
        grid.getInput('b')
        grid.getInput('c')
        grid.getInput('d')
        grid.getInput('e')
        grid.getInput('aa')
        grid.getInput('bb')
        grid.getInput('cc')
        grid.getInput('dd')
        grid.getInput('ee')

        grid.getInput('1')
        grid.getInput('2')
        grid.getInput('3')
        grid.getInput('4')
        grid.getInput('5')
        grid.getInput('11')
        grid.getInput('22')
        grid.getInput('33')
        grid.getInput('44')
        grid.getInput('55')
    end

    def runTest(difficulty, maxGridsToRun)
        count = 0
        loop do
            count += 1
            gridSize = difficulty.to_i + 2
            trinketsAmount = (gridSize*gridSize*2/3).floor()

            myGrid = Grid.new(gridSize, difficulty)
            myGrid.fillWithTrinkets(trinketsAmount)
            myGrid.printGrid()

            #spawn light
            myGrid.lightMode = Light
            spawnInput(myGrid)

            #spawn light
            myGrid.lightMode = Sonar
            spawnInput(myGrid)

            #spawn light
            myGrid.lightMode = BlueLight
            spawnInput(myGrid)

            if count == maxGridsToRun
                break
            end
        end
    end
end
