module Hand
  ACE_HIGH_VALUE = 11
  ACE_LOW_VALUE = 1

  def busted?
    total > Game::WINNING_TOTAL
  end

  def total
    @cards.map { |card| get_value(card[0]) }.sum
  end

  private

  def get_value(card)
    case card
    when 'Ace' then calculate_ace
    when 'Ten', 'Jack', 'Queen', 'King' then 10
    else
      card.to_i
    end
  end

  def total_without_ace
    non_ace_cards = @cards.reject { |card| card[0] == "Ace" }
    non_ace_cards.map { |card| get_value(card[0]) }.sum
  end

  def calculate_ace
    if count_aces > 1
      calculate_multiple_aces
    else
      calculate_single_ace
    end
  end

  def calculate_multiple_aces
    ace_value_total = ACE_HIGH_VALUE + (count_aces - 1)
    if (total_without_ace + ace_value_total) > Game::WINNING_TOTAL
      count_aces
    else
      ace_value_total
    end
  end

  def calculate_single_ace
    if (total_without_ace + ACE_HIGH_VALUE) > Game::WINNING_TOTAL
      ACE_LOW_VALUE
    else
      ACE_HIGH_VALUE
    end
  end

  def count_aces
    @cards.count { |card| card[0] == "Ace" }
  end
end

class Participant
  include Hand

  attr_accessor :cards, :score

  def initialize
    @score = 0
  end
end

class Player < Participant
end

class Dealer < Participant
  STAY = 17
end

class Deck
  CARDS = %w(Ace 2 3 4 5 6 7 8 9 Ten Jack Queen King)
  SUITS = %w(Hearts Spades Clubs Diamonds)

  def initialize
    @deck = CARDS.product(SUITS)
    @deck.shuffle!
  end

  def [](card)
    @deck[card]
  end

  def deal(participant)
    participant.cards << @deck.shift
  end
end

class Game
  VALID_CHOICES = %w(hit h stay s)
  WINNING_TOTAL = 21
  attr_accessor :deck, :player, :dealer

  def initialize
    @player = Player.new
    @dealer = Dealer.new
  end

  def start
    loop do
      welcome_message
      deal_hand_and_take_turns
      increment_score
      show_result
      break if overall_winner?
      answer = deal_next_hand
      next unless answer == ''
    end

    announce_overall_winner
  end

  private

  def deal_hand_and_take_turns
    deal
    show_initial_cards
    player_turn
    dealer_turn
  end

  def prompt(msg)
    puts "=> #{msg}"
  end

  def clear
    system('clear')
  end

  def welcome_message
    clear
    prompt "Welcome to #{WINNING_TOTAL}! The first player to 5 wins! The " \
      "current score is: Player #{@player.score} Dealer: #{@dealer.score}"
  end

  def deal
    @player.cards = []
    @dealer.cards = []
    @deck = Deck.new
    2.times do
      @deck.deal(player)
      @deck.deal(dealer)
    end
  end

  def display_hand(hand)
    "#{hand[0]} of #{hand[1]}"
  end

  def show_initial_cards
    prompt "Dealer has #{display_hand(@dealer.cards[1])} and an unknown card"
    prompt "Player has #{display_hand(@player.cards[0])} and " \
      "#{display_hand(@player.cards[1])}"
  end

  def say_dealer_hand
    prompt "Dealer flips up a #{display_hand(@dealer.cards[0])} " \
      "to go with the #{display_hand(@dealer.cards[1])} " \
      "for a total of #{@dealer.total}"
  end

  # rubocop:disable Metrics/MethodLength
  def player_turn
    loop do
      prompt "Player total is #{@player.total}"
      answer = hit_or_stay
      break if answer == "stay" || answer == "s"
      prompt "Player dealt #{display_hand(@deck[0])}"
      @deck.deal(player)

      if @player.busted?
        prompt "Player busted!"
        break
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  def dealer_turn
    say_dealer_hand
    return if @player.busted?

    until @dealer.total >= Dealer::STAY
      prompt "Dealer dealt #{display_hand(@deck[0])}"
      @deck.deal(dealer)

      if @dealer.busted?
        prompt "Dealer busted!"
        break
      end
    end
  end

  def hit_or_stay
    answer = ''
    loop do
      prompt "(h)it or (s)tay"
      answer = gets.chomp
      break if VALID_CHOICES.include?(answer)
      prompt "Please select a valid choice"
    end

    answer
  end

  def compare_totals
    if @player.total > @dealer.total
      'Player'
    elsif @dealer.total > @player.total
      'Dealer'
    end
  end

  def determine_winner
    if @player.busted?
      'Dealer'
    elsif @dealer.busted?
      'Player'
    else
      compare_totals
    end
  end

  def increment_score
    case determine_winner
    when 'Player' then @player.score += 1
    when 'Dealer' then @dealer.score += 1
    end
  end

  def show_result
    prompt "Player has #{@player.total}. Dealer has #{@dealer.total}."
    case determine_winner
    when 'Player' then prompt 'Player wins!'
    when 'Dealer' then prompt 'Dealer wins!'
    else
      prompt "It's a tie!"
    end
  end

  def deal_next_hand
    prompt "Press enter to deal the next hand"
    gets.chomp
  end

  def overall_winner?
    @player.score == 5 || @dealer.score == 5
  end

  def announce_overall_winner
    winner = @player.score > @dealer.score ? "Player" : "Dealer"
    prompt "#{winner} wins the match!"
  end
end

Game.new.start
