require 'json'

class Game
  def initialize
    @answer = random_word
    @player_view = Array.new(@answer.length, '_')
    @incorrect_guesses = Array.new
    @score = 0
    p @answer # delte this later
  end

  def random_word
    words = File.readlines('google-10000-english-no-swears.txt')
    word_choices = []
    words.each do |word|
      word = word.chomp
      word_choices << word if word.length > 4 && word.length < 13
    end
    word_choices.sample
  end

  def start_game
    @winner = nil
    while @score < 6 && @winner.nil?
      puts "\n" * 100
      take_turn_dialog
      take_turn(gets.chomp.downcase)
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
      # creates a mock answer that replaces the characters we have already guessed correctly with 0s
      # this helps prevent a bug related to dupliacte characters in @answer
      answer_arr = subtracted_answer_array
      # see if our guess is included in the sanitized array
      if answer_arr.include?(guess)
        # determine location based off sanitized input to prevent bug related to duplicate characters in @answer
        @player_view[answer_arr.index(guess)] = guess
      else
        @incorrect_guesses << guess
        @score += 1
      end
    elsif @answer == guess
      @winner = true
    elsif guess == 'save'
      save_json
    elsif guess == 'load'
      load_json
    else
      puts 'WRONG!'
      @score += 1
    end
    # if @player_view doesn't contain any mystery fields (i.e. '_') then the word has been solved, and the game is over
    @winner = true unless @player_view.any?('_')
  end

  # replaces all elements we have already guessed in the answer to zero
  # this helps prevents a duplicate error
  def subtracted_answer_array
    answer_arr = @answer.split('')
    @player_view.each do |letter|
      unless letter == '_'
        answer_arr[answer_arr.index(letter)] = '0'
      end
    end
    answer_arr
  end

  def save_json
    json = JSON.generate(
      {
        answer: @answer,
        player_view: @player_view,
        incorrect_guesses: @incorrect_guesses,
        score: @score,
        winner: @winner
      }
    )
    File.open('save_data.txt', 'w') { |file| file.write(json) }
  end

  def load_json
    ruby_hash = JSON.parse(File.read('save_data.txt'))

    @answer = ruby_hash['answer']
    @player_view = ruby_hash['player_view']
    @incorrect_guesses = ruby_hash['incorrect_guesses']
    @score = ruby_hash['score']
    @winner = ruby_hash['winner']
  end
end

Game.new.start_game

# max number of turns = 6
#  O
# /|\
# / \
