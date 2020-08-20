class Move
  VALUES = %w(rock paper scissors lizard spock)

  def initialize(value)
    @value = value
  end

  def rock?
    @value == 'rock'
  end

  def paper?
    @value == 'paper'
  end

  def scissors?
    @value == 'scissors'
  end

  def lizard?
    @value == 'lizard'
  end

  def spock?
    @value == 'spock'
  end

  def to_s
    @value
  end
end

class Rock < Move
  def >(other_move)
    (other_move.lizard?) || (other_move.scissors?)
  end

  def <(other_move)
    (other_move.paper?) || (other_move.spock?)
  end
end

class Paper < Move
  def >(other_move)
    (other_move.rock?) || (other_move.spock?)
  end

  def <(other_move)
    (other_move.scissors?) || (other_move.lizard?)
  end
end

class Scissors < Move
  def >(other_move)
    (other_move.paper?) || (other_move.lizard?)
  end

  def <(other_move)
    (other_move.rock?) || (other_move.spock?)
  end
end

class Spock < Move
  def >(other_move)
    (other_move.scissors?) || (other_move.rock?)
  end

  def <(other_move)
    (other_move.paper?) || (other_move.lizard?)
  end
end

class Lizard < Move
  def >(other_move)
    (other_move.spock?) || (other_move.paper?)
  end

  def <(other_move)
    (other_move.scissors?) || (other_move.rock?)
  end
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

  def get_move(choice)
    case choice
    when 'rock' then Rock.new('rock')
    when 'paper' then Paper.new('paper')
    when 'scissors' then Scissors.new('scissors')
    when 'lizard' then Lizard.new('lizard')
    when 'spock' then Spock.new('spock')
    end
  end
end

class Human < Player
  def set_name
    system('clear')
    n = ""
    loop do
      puts "What is your name?"
      n = gets.strip.chomp
      break unless n.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def translate_choice(choice)
    case choice
    when 'r', 'rock' then 'rock'
    when 'p', 'paper' then 'paper'
    when 'sc', 'scissors' then 'scissors'
    when 'l', 'lizard' then 'lizard'
    when 'sp', 'spock' then 'spock'
    end
  end

  def choose
    choice = nil
    loop do
      puts "Please choose [r]ock, [p]aper, [sc]issors, [l]izard, or [sp]ock:"
      choice = translate_choice(gets.downcase.chomp)
      break if Move::VALUES.include? choice
      puts "Sorry, invalid choice."
    end
    self.move = get_move(choice)
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def choose
    self.move = get_move(Move::VALUES.sample)
  end
end

class R2D2 < Computer
  def set_name
    self.name = 'R2D2'
  end

  def choose
    self.move = Move.new('rock')
  end
end

class Hal < Computer
  def set_name
    self.name = 'Hal'
  end

  def choose
    self.move = [Move.new('scissors'), Move.new('scissors'),
                 Move.new('scissors'), Move.new('rock')].sample
  end
end

class History
  attr_writer :player, :computer

  def initialize
    @player = []
    @computer = []
  end

  def add(player_move, computer_move)
    @player << player_move
    @computer << computer_move
  end

  def display_name(name)
    puts "#{name} chose the following moves: "
  end

  def show(human, computer)
    show_player(human)
    show_computer(computer)
  end

  def show_player(name)
    display_name(name)
    puts @player.join(', ')
  end

  def show_computer(name)
    display_name(name)
    puts @computer.join(', ')
  end
end

class RPSGame
  attr_accessor :human, :computer, :history

  def get_computer(computer)
    @computer = case computer.name
                when 'R2D2' then R2D2.new
                when 'Hal' then Hal.new
                else computer
                end
  end

  def initialize
    @human = Human.new
    @computer = get_computer(Computer.new)
    @history = History.new
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, Lizard, Spock!"
    puts "You will be playing a tournament against #{computer.name} today."
    puts "The first to #{Score::WINNING_SCORE} wins!"
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
      break if ['y', 'n', 'yes', 'no'].include? answer.downcase
      puts "Sorry, must be y or n."
    end

    answer.downcase == 'y' || 'yes'
  end

  def game_loop(score)
    loop do
      human.choose
      computer.choose
      history.add(human.move, computer.move)
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
      play_again? ? system('clear') : break
    end

    history.show(human.name, computer.name)
    display_goodbye_message
  end
end

RPSGame.new.play
