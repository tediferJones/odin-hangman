class Game
  def initialize
    @answer = random_word()
    @player_view = Array.new(@answer.length, '_')
    @incorrect_guesses = Array.new
    @score = 0
    p @answer # delte this later
    # start_game()
  end

  def random_word()
    words = File.readlines('google-10000-english-no-swears.txt')
    word_choices = []
    words.each do |word|
      word = word.chomp
      if word.length > 4 && word.length < 13
        word_choices << word
      end
    end
    word_choices.sample
  end

  def start_game()
    @winner = nil
    while @score < 6 && @winner == nil
      take_turn_dialog
      take_turn(gets.chomp)
      # print scoreboard
    end
    if @winner == true
      puts 'You figured out the word!'
    else
      puts 'You did not figure out the word'
    end
    puts "The word was #{@answer}"
  end

  def take_turn_dialog
    p @player_view
    p @incorrect_guesses
    puts "You have #{6 - @score} guesses left"
    puts 'Enter 1 letter or the whole word'
  end

  def take_turn(guess)
    # should be able to take a single letter as a guess or be able to guess whole word
    if guess.length == 1
      # see if guess is in word
      if @answer.split('').any?(guess)
        # determine index of that letter in @answer, asign the value of guess to that index position in @player_view
        # PROBLEM: in case where word has repeated letters (example: "skill"), the letter exists in the word, but index
        # only returns the first occurance of said value, leaving you trapped in a loop
        # TRY: removing one instance of each letter from @answer that have already been used, then comparing
        # figuring out the true index afterwords will be difficult  
        @player_view[@answer.split('').index(guess)] = guess
      else
        @incorrect_guesses << guess
        @score += 1
      end
    else
      #check if word matches answer, if it does, game over, else "WRONG", no other feedback
      if @answer == guess
        @winner = true
      else
        puts "WRONG!"
        @score += 1
      end
    end
    # if @player_view doesn't contain any mystery fields (i.e. '_') then the word has been solved, and the game is over
    @winner = true unless @player_view.any?('_')
  end

  def printer

  end
end

Game.new.start_game()

# max number of turns = 6
# O
#/|\
#/ \
 