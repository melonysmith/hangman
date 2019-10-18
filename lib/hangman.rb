require "yaml"

WORDS = File.open("5desk.txt").readlines.map { |word| word.strip }.select { |word| word.length >= 5 && word.length <= 12 }

class Hangman
	attr_accessor :wrong_guesses

	def initialize
		@word = WORDS.sample.downcase
		@letters = word.split("")
		@hidden_letters = letters.map { |letter| "_" }
		@guessed_letters = []
		@wrong_guess = true
		@wrong_guesses = 0
		@game_over = false
	end

	def reset
		self.word = WORDS.sample.downcase
		self.letters = word.split("")
		self.hidden_letters = letters.map { |letter| "_" }
		self.guessed_letters = []
		self.wrong_guess = true
		self.wrong_guesses = 0
		self.game_over = false
	end

	def play
		show_title

		until game_over
		show_hangman(wrong_guesses)
		puts "Correct Guesses: #{guessed_letters.join(" ")}\nWrong Guesses: #{wrong_guesses}"
		display_hidden_letters
		self.wrong_guess = false

		puts "\nGuess a letter. You can also type \"1\" to save your game or type \"2\" to load your last saved game: "
		begin
			guess = gets.chomp.downcase.match(/[a-z12]/)[0]
		rescue StandardError=>e
			puts "You can only guess letters!"
			redo
		end

		check_guess(guess)
		add_guessed_letter(guess)
		add_wrong_guess(guess)

		check_for_win_condition
		check_for_loss_condition
	end

	puts "\nPlay again? (y/n)"
	restart = gets.chomp[0].downcase
	if restart == "y"
		self.reset
		self.play
	else
		puts "Thanks for playing!"
		exit
	end
end

private

attr_accessor :words, :word, :letters, :hidden_letters, :guessed_letters, :wrong_guess, :game_over

def display_hidden_letters
	puts hidden_letters.join(" ")
end

def already_guessed?(guess)
	guessed_letters.include?(guess)
end

def check_guess(guess)
	if guess == "1"
		puts "Saving..."
		save_game
		puts "Saved!"
	elsif guess == "2"
		Hangman.load_game
	elsif already_guessed?(guess)
		puts "You already guessed that letter."
	elsif letters.include?(guess)
		letters.each_with_index do |l, idx|
			if guess == l
				hidden_letters[idx] = l
			end
		end
	else
		self.wrong_guess = true
	end
end

def add_guessed_letter(guess)
	guessed_letters.push(guess) if !guessed_letters.include?(guess) && guess != "1" && guess != "2"
end

def add_wrong_guess(guess)
	self.wrong_guesses += 1 if wrong_guess
end

def show_title

puts %Q{
    HANGMAN
}

end

def show_hangman(guesses)
	case guesses
	when 0
		puts %Q{
        ____
       |/   |
       |    
       |   
       |    
       |   
   ____|____    
		  }
	when 1
		puts %Q{
        ____
       |/   |
       |    O
       |   
       |    
       |   
   ____|____    
		}
	when 2
		puts %Q{
        ____
       |/   |
       |    O
       |    |
       |    |
       |   
   ____|____    
		}
	when 3
		puts %Q{
        ____
       |/   |
       |    O
       |   /|
       |    |
       |    
   ____|____    
		}
	when 4
		puts %Q{
        ____
       |/   |
       |    O
       |   /|\\
       |    |
       |   
   ____|____    
		}
	when 5
		puts %Q{
        ____
       |/   |
       |    O
       |   /|\\
       |    |
       |   /
   ____|____    
		}
	when 6
		puts %Q{
        ____
       |/   |
       |    O
       |   /|\\
       |    |
       |   / \\
   ____|____    
		}
	end
end

def save_game
	save_data = YAML::dump(self)
	File.open("save_game.yaml","w"){ |file| file.write(save_data) }
end

def self.load_game
	if File.exists?("save_game.yaml")
		puts "Loading..."
		YAML.load_file("save_game.yaml").play
	else
		puts "Nothing to load! Continuing current game..."
	end
end

def check_for_win_condition
	if !hidden_letters.include?("_")
		puts "You correctly guessed the word #{word}!"
		self.game_over = true
	end
end

def check_for_loss_condition
	if wrong_guesses == 6
		show_hangman(wrong_guesses)
		puts "You made too many wrong guesses. You have been hanged!\nThe word was: #{word}"
		self.game_over = true
	end
end

end

hangman = Hangman.new
hangman.play
