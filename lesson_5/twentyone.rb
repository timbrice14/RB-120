require 'pry'

module Hand
  WINNING_TOTAL = 21
  ACE_HIGH_VALUE = 11
  ACE_LOW_VALUE = 1

  def busted?
    total > WINNING_TOTAL
  end

  def hit; end

  def stay; end

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
    if busted?(total_without_ace + ace_value_total)
      count_aces
    else
      ace_value_total
    end
  end

  def calculate_single_ace
    if busted?(total_without_ace + ACE_HIGH_VALUE)
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

  attr_accessor :cards

  def initialize
    @cards = []
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
  attr_accessor :deck, :player, :dealer

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def start
    deal_cards
    show_initial_cards
    player_turn
    dealer_turn
    show_result
  end

  private

  def prompt(msg)
    puts "=> #{msg}"
  end

  def deal_cards
    @deck.deal(player)
    @deck.deal(dealer)
    @deck.deal(player)
    @deck.deal(dealer)
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

  def dealer_turn
    say_dealer_hand
    return if @player.busted?

    until @dealer.total > Dealer::STAY
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

  def show_result
    prompt "Player has #{@player.total}. Dealer has #{@dealer.total}."
    case determine_winner
    when 'Player' then prompt 'Player wins!'
    when 'Dealer' then prompt 'Dealer wins!'
    else
      prompt "It's a tie!"
    end
  end
end

Game.new.start
