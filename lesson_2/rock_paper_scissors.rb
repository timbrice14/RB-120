class Move
  VALUES = ['rock', 'paper', 'scissors', 'spock', 'lizard']

  def initialize(value)
    @value = value
  end

  def >(other_move)
    winning_outcomes = { rock: ['lizard', 'scissors'],
                         paper: ['rock', 'spock'],
                         scissors: ['lizard', 'paper'],
                         spock: ['scissors', 'rock'],
                         lizard: ['spock', 'paper'] }
    winning_outcomes[@value.to_sym].include?(other_move.value)
  end

  def <(other_move)
    losing_outcomes = { rock: ['paper', 'spock'],
                        paper: ['scissors', 'lizard'],
                        scissors: ['spock', 'rock'],
                        spock: ['lizard', 'paper'],
                        lizard: ['scissors', 'rock'] }
    losing_outcomes[@value.to_sym].include?(other_move.value)
  end

  def rock_wins?(other_move)
    (other_move.scissors?) || (other_move.lizard?)
  end

  def rock_loses?(other_move)
    (other_move.rock?) || (other_move.spock?)
  end

  def to_s
    @value
  end

  protected

  attr_reader :value
end

class Score
  WINNING_SCORE = 5

  def initialize(human, computer)
    @human = human
    @computer = computer
    @human_score = 0
    @computer_score = 0
  end

  def update
    if @human.move > @computer.move
      @human_score += 1
    elsif @human.move < @computer.move
      @computer_score += 1
    end
  end

  def display
    puts "Current score #{@human.name}: #{@human_score} " \
       "#{@computer.name}: #{@computer_score}"
  end

  def game_winner?
    @human_score >= WINNING_SCORE || @computer_score >= WINNING_SCORE
  end

  def display_game_winner
    if @human_score > @computer_score
      puts "Congrats to #{@human.name}, who wins by a score of " \
      "#{@human_score} to #{@computer_score}"
    else
      puts "Congrats to #{@computer.name}, who wins by a score of " \
        "#{@computer_score} to #{@human_score}"
    end
  end
end

class Player
  attr_accessor :move, :name

  def initialize
    set_name
  end
end

class Human < Player
  def set_name
    n = ""
    loop do
      puts "What is your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, scissors, lizard, or spock:"
      choice = gets.chomp
      break if Move::VALUES.include? choice
      puts "Sorry, invalid choice."
    end
    self.move = Move.new(choice)
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def choose
    self.move = Move.new(Move::VALUES.sample)
  end
end

class RPSGame
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, Lizard, Spock!"
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors, Lizard, Spock. Good bye!"
  end

  def display_moves
    puts "#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}"
  end

  def display_winner
    if human.move > computer.move
      puts "#{human.name} won!"
    elsif human.move < computer.move
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include? answer.downcase
      puts "Sorry, must be y or n."
    end

    answer.downcase == 'y'
  end

  def game_loop(score)
    loop do
      human.choose
      computer.choose
      display_moves
      display_winner
      score.update
      score.display
      break if score.game_winner?
    end
  end

  def play
    display_welcome_message

    loop do
      score = Score.new(human, computer)
      game_loop(score)
      score.display_game_winner
      break unless play_again?
    end

    display_goodbye_message
  end
end

RPSGame.new.play
