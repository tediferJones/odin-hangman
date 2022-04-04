# frozen_string_literal: true

require 'json'

# should initialize a word, create an array of mystery characters with length of word, then allow player to make a guess
class Game
  def initialize
    @answer = random_word
    @player_view = Array.new(@answer.length, '_')
    @incorrect_guesses = []
    @score = 0
    @winner = nil
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
    while @score < 6 && @winner.nil?
      take_turn_dialog
      take_turn(gets.chomp.downcase)
    end
    if @winner == true
      puts "You figured out the word, it was #{@answer}"
    else
      puts "You did not figure out the word, it was #{@answer}"
    end
  end

  def take_turn_dialog
    puts "\n" * 100
    p @player_view
    puts "Incorrect Guesses: #{@incorrect_guesses.join(', ')}"
    puts "You have #{6 - @score} guesses left"
    puts 'Enter 1 letter to guess that letter, or enter the whole word if you think you know what it is'
    puts "You can enter 'save' to save the current game, or 'load' to load the prevously saved game"
  end

  def take_turn(guess)
    # should be able to take a single letter as a guess or be able to guess whole word
    if guess.length == 1
      guess_letter(guess)
    else
      guess_word(guess)
    end
  end

  def guess_letter(letter)
    answer_arr = subtracted_answer_array
    # see if our guess is included in the mock answer array
    if answer_arr.include?(letter)
      # determine location based off sanitized input to prevent bug related to duplicate characters in @answer
      @player_view[answer_arr.index(letter)] = letter
    elsif !@incorrect_guesses.include?(letter)
      @incorrect_guesses << letter
      @score += 1
    end
    # if @player_view doesn't contain any mystery fields (i.e. '_') then the word has been solved, and the game is over
    @winner = true unless @player_view.any?('_')
  end

  def guess_word(word)
    case word
    when @answer
      @winner = true
    when 'save'
      save_json
    when 'load'
      load_json
    else
      @score += 1
    end
  end

  # changes all elements we have already correctly guessed in the answer to zero
  # this helps prevents a duplicate error
  def subtracted_answer_array
    answer_arr = @answer.split('')
    @player_view.each do |letter|
      answer_arr[answer_arr.index(letter)] = '0' unless letter == '_'
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
