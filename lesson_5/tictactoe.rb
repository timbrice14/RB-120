require 'pry'

class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                  [[1, 5, 9], [3, 5, 7]]
  WINNING_SQUARES = 3
  AT_RISK_SQUARES = 2

  def initialize
    @squares = {}
    reset
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if identical_markers?(squares, WINNING_SQUARES)
        return squares.first.marker
      end
    end
    nil
  end

  def at_risk_square?(marker)
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      return true if count_squares(squares, marker) == \
                     AT_RISK_SQUARES && one_unmarked_square?(squares)
    end
    false
  end

  def find_at_risk_square
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if identical_markers?(squares, AT_RISK_SQUARES)
        at_risk_square = squares.index do |sq|
          sq.marker == Square::INITIAL_MARKER
        end
        return line[at_risk_square]
      end
    end
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def best_square_unmarked?
    @squares[Square::BEST_SQUARE].marker == Square::INITIAL_MARKER
  end

  private

  def identical_markers?(squares, num)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != num
    markers.min == markers.max
  end

  def one_unmarked_square?(squares)
    squares.select(&:unmarked?).count == 1
  end

  def count_squares(squares, marker)
    squares.count { |sq| sq.marker == marker }
  end
end

class Square
  INITIAL_MARKER = " "
  BEST_SQUARE = 5

  attr_accessor :marker

  def initialize(marker = INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

class Player
  attr_accessor :score, :name

  def initialize
    @score = 0
    set_name
  end
end

class Human < Player
  attr_accessor :marker

  def win
    puts "You won!"
    @score += 1
  end

  def set_name
    n = ""
    loop do
      puts "What is your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a value."
    end
    @name = n
  end

  def choose_marker
    loop do
      puts "Please choose a one character marker:"
      @marker = gets.chomp
      break if @marker.size == 1 && @marker != Computer::MARKER
      puts "Sorry, that is not a valid choice."
    end
  end
end

class Computer < Player
  MARKER = "O"

  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def win
    puts "Computer won!"
    @score += 1
  end
end

class TTTGame
  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Human.new
    @computer = Computer.new
    @current_marker = first_to_move
  end

  def first_to_move
    human.marker
  end

  def play
    clear
    display_welcome_message
    human.choose_marker
    @current_marker = first_to_move
    main_game
    display_goodbye_message
  end

  private

  def clear
    system('clear')
  end

  def display_welcome_message
    puts "Welcome to Tic Tac Toe #{human.name}!"
    puts "You are playing against #{computer.name} today!"
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def display_board
    puts "You're a #{human.marker} #{computer.name} a #{Computer::MARKER}."
    puts ""
    board.draw
    puts ""
  end

  def joinor(squares, joiner = ', ', conjuction = 'or')
    return squares[0] if squares.size == 1
    squares[-1] = "#{conjuction} #{squares.last}"
    squares.join(joiner)
  end

  def human_moves
    puts "Choose a square (#{joinor(board.unmarked_keys)}): "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end

    board[square] = human.marker
  end

  def computer_moves
    if board.at_risk_square?(Computer::MARKER) || \
       board.at_risk_square?(human.marker)
      board[board.find_at_risk_square] = Computer::MARKER
    elsif board.best_square_unmarked?
      board[Square::BEST_SQUARE] = Computer::MARKER
    else
      board[board.unmarked_keys.sample] = Computer::MARKER
    end
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      human.win
    when Computer::MARKER
      computer.win
    else
      puts "It's a tie!"
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n"
    end

    answer == 'y'
  end

  def reset
    board.reset
    @current_marker = first_to_move
    clear
  end

  def display_play_again_message
    puts "Let's play again!"
  end

  def display_current_score
    puts "The current score is #{human.name}: #{human.score} " \
      "#{computer.name}: #{computer.score}"
    puts ""
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = Computer::MARKER
    else
      computer_moves
      @current_marker = human.marker
    end
  end

  def human_turn?
    @current_marker == human.marker
  end

  def main_game
    loop do
      display_board
      player_move
      display_result
      break unless play_again?
      reset
      display_play_again_message
      display_current_score
    end
  end

  def player_move
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
    end
  end
end

game = TTTGame.new
game.play
