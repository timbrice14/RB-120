

module Hand
    def busted?
    end

    def hit
    end

    def stay
    end

    def total
    end
end

class Participant
end

class Player < Participant
    include Hand

    def initialize
    end
end

class Dealer < Participant
    def initialize
    end
end

class Deck
    def initialize
    end

    def deal
    end
end

class Game
    def start
        deal_cards
        show_initial_cards
        player_turn
        dealer_turn
        show_result
    end
end

Game.new.start
