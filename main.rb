require 'pry'

load 'bayes_spam_filter.rb'


class Main

  # Returns the content of the CSV as hash of hashs. Each line is a hash
  hash = BayesSpamFilter.get_sample_hashs #CSVParser.csv_to_hash
  training_hashes_size = (hash.size * 0.1).to_int

  puts "Choose the method:\n Type\n 1 to use the Bernoulli method\n 2 to use the Normal method and\n 3 to use Binomial method."
  distribution_option = gets.chomp

  # User chooses the distribuction to generate the results
	if (distribution_option != '1' && distribution_option != '2' && distribution_option != '3')
	  puts("You need to enter 1, 2 or 3.")
	elsif (distribution_option == '1')
		puts "Using the Bernoulli Distribution to generate the results:"
	elsif (distribution_option == '2')
		puts "Using the Normal Distribution to generate the results"
	elsif (distribution_option == '3')
		puts "Using the Binomial Distribution to generate the results"
  end

  puts "There are a total of 57 features in the spam sample."
  puts "How many features? Type, e.g., '1' to use 1 feature, '10' to use 10 features or how many you want.
       To use all features, type '57' or simply 'all'."
  features_quantity = gets.chomp

  # Trains the algorithm
  BayesSpamFilter.train_algorithm(hash, training_hashes_size, distribution_option, features_quantity)

end
