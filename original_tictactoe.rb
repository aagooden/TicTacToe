class Game

    def initialize
        @board = Board.new
        system("clear")

        puts "Hello player 1.  What is your name?"
        player1 = gets.chomp
        puts "Thank you #{player1}, you will be X's"
        puts ""
        puts ""
        @player1 = Player.new(player1, "X")

        puts "Hello player 2.  What is your name?"
        player2 = gets.chomp
        @player2 = Player.new(player2, "O")
        puts "Hello #{player2}, you will be O's"
        puts ""
        puts "Press Enter to start the game"
        gets.chomp
        @turn = true

    end

    def play
        @board.render
        player = ""
        loop do
            if @turn == true
                player = @player1
            else
                player = @player2
            end

            loop do
                puts "#{player.name}, enter the number of the position where you would like to play."
                position = gets.chomp
                position = position.to_i
                if @board.check(position)
                    @board.change_state(player.piece, position)
                    player.update_positions(position)
                    # puts "Positions = #{player.positions}"
                    break
                else
                    puts "That position is occupied...try again!"
                    puts "Press Enter to continue..."
                    gets.chomp
                end
            end

            @board.render
            @turn = !@turn


            if player.check_winner == true
                puts "Congratulations #{player.name}, you WIN!!!!!"
                player.increase_score
                break
            elsif @board.check_tie
                puts "That one was a tie!"
                break
            end
        end
            puts "The current score is..."
            puts ""
            puts "#{@player1.name}: #{@player1.score}"
            puts "#{@player2.name}: #{@player2.score}"
            puts ""
            puts "Would you like to play again? (y or n)"
        loop do
            again = gets.chomp

            if again == "n"
                break
            elsif again == "y"
                @board = Board.new
                @player1.positions=([])
                @player2.positions=([])
                play
            end
            break
        end


    end
end


class Board

    attr_accessor :state

    def initialize
        @state = [1,2,3,4,5,6,7,8,9]
    end

    def change_state(piece, position)
        @state[position-1] = piece
    end

    def check(position)
        if @state[position -1] == "X" || @state[position -1] == "Y"
            false
        else
            true
        end
    end

    def check_tie
        @state.all? {|i| i.is_a?(String) }
    end

    def render
        p = @state
        system("clear")
        puts ''
        puts ''
        puts ''

        puts "                     | #{p[0]}| #{p[1]}| #{p[2]}|"
        puts "                     ---+--+---"
        puts "                     | #{p[3]}| #{p[4]}| #{p[5]}|"
        puts "                     ---+--+---"
        puts "                     | #{p[6]}| #{p[7]}| #{p[8]}|"

        puts ''
        puts ''
        puts ''

    end

end


class Player

    attr_accessor :name, :piece

    def initialize(name, piece)
        @piece = piece
        @name = name
        @score = 0
        @positions = []
    end

    def update_positions(position)
        @positions.push(position-1)
    end

    def positions
        @positions
    end

    def positions=(new)
        @positions = new
    end

    def increase_score
        @score +=1
    end

    def score
        @score
    end

    def check_winner
        winner = false
        winning_combinations = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [6,4,2]]
        winning_combinations.each do |group|
            contain = 0

            group.each do |num|
                if positions.include?(num)
                    contain+=1
                end
                if contain == 3
                    winner = true
                end
            end
        end
        return winner
    end

end



p = Game.new
p.play
