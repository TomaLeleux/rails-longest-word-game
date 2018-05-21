require 'open-uri'
require 'json'
require 'time'

START = Time.now

class GamesController < ApplicationController
  def new
    @letters = generate_grid(rand(2..15))
    @start = Time.now.to_s
  end

  def score
    @grid = []
    @end = Time.now
    @word = params[:word]
    @grid = params[:grid].chars
    @start = START # params[:start]
    @result = run_game(@word, @grid, @start, @end)
  end

  def generate_grid(grid_size)
    Array.new(grid_size) { [*'A'..'Z'].sample }
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    attempt_result = get_info_api(attempt)
    in_grid = check_letter_count(grid, attempt.upcase.split(''))
    time = (end_time.to_time - start_time.to_time).floor
    score = get_score(attempt, time)
    get_result(attempt_result, in_grid, time, score)
  end

  def get_result(attempt_result, in_grid, time, score)
    return { time: time, score: score, message: "Well done" } if attempt_result["found"] == true && in_grid == true
    return { time: time, score: 0, message: "not in the grid" } if attempt_result["found"] == true && in_grid == false
    return { time: time, score: 0, message: "not in the grid" } unless in_grid
    return { time: time, score: 0, message: "not an english word" }
  end

  def get_info_api(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    result = URI(url).read
    JSON.parse(result)
  end

  def get_score(attempt, time)
    attempt.size.fdiv(time)
  end

  def check_letter_count(grid, word)
    word.all? { |x| word.count(x) <= grid.count(x) }
  end

  # def check_word_in_grid(grid, word)
  #   return word.all? { |letter| grid.include?(letter) }
  # end
end
