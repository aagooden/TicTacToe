class Game

  def initialize
      @board = Board.new
      system("clear")

      puts "How many players?"
      @number_of_players = gets.chomp



      puts "Hello player 1.  What is your name?"
      player1 = gets.chomp
      puts "Thank you #{player1}, you will be X's"
      puts ""
      puts ""
      @player1 = Player.new(player1, "X", @board)

      if @number_of_players == "2"

        puts "Hello player 2.  What is your name?"
        player2 = gets.chomp
        # @player2 = Computer.new(player2, "O", @board)
        @player2 = Player.new(player2, "O", @board)
        puts "Hello #{player2}, you will be O's"
        puts ""
        puts "Press Enter to start the game"
        gets.chomp
        @turn = true
      else
        player2 = "Computer"
        @player2 = Computer.new(player2, "O", @board)
        puts "The Computer will be O's"
        puts ""
        puts "Press Enter to start the game"
        gets.chomp
        @turn = true

        puts "What level of difficlty would you like?"
        puts "1 = Random Opponent"
        puts "2 = Sequential Opponent"
        puts "3 = Unbeatable Opponent"
        @difficulty = gets.chomp
      end

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
						# p "The class of player is #{player.class}"
							if player.class == Computer
                # puts "The difficulty level is #{@difficulty}"
                  if @difficulty == "1"
                    position = player.random_move(@board.state, @player2.piece, @player1.piece)
                  elsif @difficulty == "2"
                    position = player.sequential_move(@board.state, @player2.piece, @player1.piece)
                  elsif @difficulty == "3"
                    position = player.move(@board.state)
                  end

									puts "The Computer's move is position (Press Enter to continue...) #{position}"
									z=gets.chomp
							else
                puts "#{player.name}, enter the number of the position where you would like to play."
                position = gets.chomp
                position = position.to_i
							end
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


    def initialize
        @state = [1,2,3,4,5,6,7,8,9]
    end

		def state
			@state
		end

    def change_state(piece, position)
        @state[position-1] = piece
        # puts "The state in change state is now #{@state}"
    end

    def check(position)
        if @state[position -1] == "X" || @state[position -1] == "O"
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


test = Board.new
puts test
p test.state

answer = test.state.include?(3)

puts answer
class Player

    attr_accessor :name, :piece

    def initialize(name, piece, board)
        @piece = piece
        @name = name
				@board = board
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


class Computer < Player

  def winning_move(overall_status,move)
    # puts "WINNING MOVE"
    overall_status.each do |temp|
      #check for winning move and play winning move
      if temp.count(self.piece) == 2
        # puts "This is group from to win function #{temp}"
        group = temp - [@opponent_piece, piece]
        # puts "Here is the move from winning function #{group}"
        if group.empty?
        else
          move = group[0]
        end
      end
    end
    # puts "Move from winning_move is #{move}"
    return move
  end


  def block(overall_status,move)
    # puts "BLOCK"
    group = []
    #check for opponent winning position and block
    overall_status.each do |temp|
    if temp.count(@opponent_piece) == 2
        # puts "Here is overall_status #{overall_status}"
        # puts "Here is the group before deleting #{temp}"
        # puts "Piece in block function is #{piece}"
        # puts "@opponent_piece in block function is #{@opponent_piece}"
        group = temp - [@opponent_piece, self.piece]
        # puts "Here is the group from blocking function #{group}"
        if group.empty?
        else
          move = group[0]
        end
      end
    end
    # puts "Move from block is #{move}"
    return move
  end


  def fork_move(overall_status, move, piece, opponent_piece)
    # puts "FORK_MOVE"
    # puts "Here is move right after entering fork_move function #{move}"
    forks = []
    positions = []
    possible =[]
    # puts "Here is overall_status in fork_move #{overall_status}"
    # puts "Here is the piec I'm deleting this cycle #{piece}"
    # puts "The other piece is #{opponent_piece}"
    overall_status.each do |temp|
      if temp.count(piece) == 1 && temp.include?(opponent_piece) == false
        group = temp - [piece]
          forks.push(group)
      end
    end
    # puts "Here is the temp array from fork move #{forks}"

    forks.each do |element|
      element.each do |n|
        positions.push(n)
      end
    end
    # puts "Here are the positions in fork_move #{positions}"

    #construct an array of possible fork moves
    for x in (1..9) do
      num = positions.count(x)
      if num > 1
        possible.push(x)
      end
    end
    # puts "Here are the possible fork moves #{possible}"

    if possible.empty?
      # puts "Here is the move from fork_move #{move}"
      return move
    else
      move = possible.first
      # puts "Here is the move form fork_move #{move}"
      return move
    end

  end


  def create_two_in_a_row(overall_status, move, piece, opponent_piece)
    # puts "CREATE_TWO_IN_A_ROW"
    possible_two_in_a_row = []
    positions = []
    #if there is an empty location that creates a two-in-a row for me(thus forcing opponent to block), play in that location
    #else move to the empty intersection space
    overall_status.each do |combo|
      if combo.count(piece) == 1 && combo.include?(opponent_piece) == false
        possible_two_in_a_row.push(combo)
      end
    end

    possible_two_in_a_row.each do |row|
      row.each do |n|
        positions.push(n)
      end
    end
    # puts "Here are possible two_in_a_row positions before deleting #{positions}"

    positions = positions - [piece]
    # positions = positions - [move]
    # puts "Here are the possible two_in_a_row positions #{positions}"
    return positions

  end

  def fork_block(overall_status, move, piece, opponent_piece)
    # puts "FORK_BLOCK"
    forks = []
    positions = []
    possible =[]
    # puts "Here is overall_status in fork_block #{overall_status}"
    # puts "Here is the piec I'm deleting this fork_block cycle #{opponent_piece}"
    # puts "The other piece is #{piece}"
    overall_status.each do |temp|
      if temp.count(opponent_piece) == 1 && temp.include?(piece) == false
        group = temp - [opponent_piece]
          forks.push(group)
      end
    end
    # puts "Here is the temp array from fork_block #{forks}"

    forks.each do |element|
      element.each do |n|
        positions.push(n)
      end
    end
    # puts "Here are the positions in fork_block #{positions}"

    #construct an array of possible fork moves...possible fork moves are any repeats in the array
    for x in (1..9) do
      num = positions.count(x)
        # puts "The count for #{x} is #{num}"
      if num > 1
        possible.push(x)
      end

    end
      # puts "Here are the possible fork block moves #{possible}"

    if possible.length == 1
      #If there is only one possible fork for the opponent, the player should block it.
      move = possible.first
      # puts "This is move from possible.first #{move}"
      return move
    elsif possible.length > 1
      # Otherwise, the player should block any forks in any way that simultaneously allows them to create two in a row...
      #the following function call finds possible two_in_a_row moves
      two_in_a_row = create_two_in_a_row(overall_status, move, piece, opponent_piece)
      # puts "Here are the two_in_a_row moves #{two_in_a_row}"
      # puts "Here is move after two_in_a_row is called #{move}"
    else
      # puts "Here is move from fork_block...should be nothing #{move}"
      return move
    end


  # The following loop compares two_in_a_row and possible arrays.  If there are matches, move becomes that match.
    # possible.each do |poss|
    #   if two_in_a_row.include?(poss)
    #     move = poss
    #     puts "This is the move from two_in_a_row and possible comparison #{move}"
    #     return move
    #   else
    #   end
    # end


  # Otherwise, the player should block any forks in any way that simultaneously allows them to create two in a row...
    #delete the fork_block moves from the possible moves
    possible.each do |num|
      if two_in_a_row.include?(num)
        # puts "This is two_in_a_row when comparing to possible fork_block moves #{two_in_a_row}"
        move = num
        two_in_a_row = two_in_a_row - [num]
      end
      # puts "This is two_in_a_row after deleting the possible fork_block moves #{two_in_a_row}"
    end

    # puts "This is move #{move}"
    # if move == nil
    #   return move
    # end

    # puts "This is two_in_a_row without possible fork_block moves #{two_in_a_row}"
    move = two_in_a_row.sample
    return move

  end

  def play_center(board,move)
    # puts "PLAY_CENTER"
    # puts "This is the board from play_center #{board}"
    if board[4] == 5
      move = 5
    end
    return move
  end

  def play_opposite_corner(board,move, piece, opponent_piece)
    # puts "PLAY_OPPOSITE_CORNER"
    corner_opposites = [[0,9],[2,7],[8,1],[6,3]]
    corner_opposites.each do |pair|
    # puts "Board corner status is #{board[pair[0]]}"
    # puts "Pair [1] is #{[pair[1]]}"
      if board[pair[0]] == opponent_piece && board[pair[1]-1] == pair[1]
        # puts "Board corner status is #{board[pair[0]]} and opponent_piece is #{opponent_piece}"

        move = pair[1]
      end
    end
    # puts "Move from play_opposite_corner is #{move}"
    return move
  end

  def empty_corner(board, move)
    # puts "EMPTY_CORNER"
    corners = [0, 2, 6, 8]
    corners.each do |corner|
      if board[corner] == corner + 1
        move = corner + 1
      end
    end
    # puts "This is move from empty_corner #{move}"
    return move
  end


  def empty_edge(board, move)
    # puts "EMPTY_EDGE"
    edges = [1, 3, 5, 7]
    edges.each do |edge|
      if board[edge] == edge + 1
        move = edge + 1
      end
    end
    # puts "This is move form empty_edge #{move}"
    return move
  end


  def random_move(board_state, piece, opponent_piece)
    @opponent_piece = opponent_piece
    move = ""
    # puts "WELCOME TO RANDOM MOVE...ENJOY YOUR STAY!"
    board = board_state
    overall_status = []
    combos = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [6,4,2]]
      combos.each do |group|
        temp = []
          group.each do |position|
            temp.push(board[position])
          end
          overall_status.push(temp)
      end
    if move == ""
      # puts "Sending to winning move"
      move = winning_move(overall_status,move)
    end

    # if move == ""
    #   puts "Sending to block"
    #   move = block(overall_status,move)
    # end

    if move == ""
    # puts "RANDOM_MOVE"
    # puts "This is the board before deleting pieces#{board}"
    # puts "This is @opponent_piece #{opponent_piece}"
    # puts "This is self.piece #{piece}"
      board = board - [opponent_piece]
      board = board - [piece]
      # puts "This is board after deleting pieces #{board}"
      move = board.sample
      # puts "This is move inside computer #{move}"
      # puts "Move coming form random is #{move}"
    end
    return move
  end


  def sequential_move(board_state, piece, opponent_piece)
      @opponent_piece = opponent_piece
    move = ""
    # puts "WELCOME TO SEQUENTIAL MOVE...ENJOY YOUR STAY!"
    board = board_state
    overall_status = []
    combos = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [6,4,2]]
      combos.each do |group|
        temp = []
          group.each do |position|
            temp.push(board[position])
          end
          overall_status.push(temp)
      end
    if move == ""
      # puts "Sending to winning move"
      move = winning_move(overall_status,move)
    end

    if move == ""
      # puts "RANDOM_MOVE"
      board = board_state
      board = board - [opponent_piece]
      board = board -[piece]
        move = board.first
        # puts "This is move inside computer #{move}"
        # puts "This is the board state #{board}"
        # puts "This is @board #{@board.state}"
        # puts "Move coming form sequential is #{move}"
    end
    return move
  end


  def move(board_state)
    # puts "HITTING THE MOVE FUNCTION"
    move = ""
    board = Array.new
    if self.piece == "O"
      @opponent_piece = "X"
    else
      @opponent_piece = "O"
    end
    #if the following routine is not performed, any changes in a variable set to @board.state will subsequently change @board.state...
    # This is essentially insulating @board.state from changes
    board_state.each do |position|
      board.push(position)
    end

    overall_status = []
    combos = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [6,4,2]]
      combos.each do |group|
        temp = []
          group.each do |position|
            temp.push(board[position])
          end
          overall_status.push(temp)
      end


    # The results of these calls are actually in the methods array...not the method calls themselves.
    # This eliminates multiple if statements.
    # methods = [
    #   winning_move(overall_status, move),
    #   block(overall_status, move),
    #   fork_move(overall_status, move, self.piece, @opponent_piece),
    #   fork_block(overall_status, move, self.piece, @opponent_piece),
    #   play_center(board,move),
    #   play_opposite_corner(board, move, self.piece, @opponent_piece),
    #   empty_corner(board, move)
    #           ]
    #   methods.each do |m|
    #     if m == ""
    #       puts "#{m} returns nothing"
    #     else
    #       puts "#{m} returns something"
    #       move = m
    #       break
    #     end
    #   end


          # These method calls, call each individual method that makes up the "unbeatable" strategy for the computer
          if move == ""
            move = winning_move(overall_status, move)
          end

          if move == ""
            move = block(overall_status, move)
          end

          if move == ""
            move = fork_move(overall_status, move, self.piece, @opponent_piece)
          end

          if move == ""
            move = fork_block(overall_status, move, self.piece, @opponent_piece)
          end

          if move == ""
            move = play_center(board,move)
          end

          if move == ""
            move = play_opposite_corner(board, move, self.piece, @opponent_piece)
          end

          if move == ""
            move = empty_corner(board, move)
          end

          if move == ""
            move = empty_edge(board,move)
          end

    # puts "Here is the final move return #{move}"
    return move
  end

end

p = Game.new
p.play
