require 'pry'

load 'bayes_spam_filter.rb'


#Kicks off the process of training and testing for the 10 folds by first creating the folds.
#validates the input and sends parameters to functions.
class Main

  #fetures = [ 'word_freq_make', :word_freq_address, :word_freq_all, :word_freq_3d, :word_freq_our, :word_freq_over, :word_freq_remove,
  #        :word_freq_internet, :word_freq_order, :word_freq_mail, :word_freq_receive, :word_freq_will, :word_freq_people, :word_freq_report,
  #        :word_freq_addresses, :word_freq_free, :word_freq_business, :word_freq_email, :word_freq_you, :word_freq_credit, :word_freq_your,
  #        :word_freq_font, :word_freq_000, :word_freq_money, :word_freq_hp, :word_freq_hpl, :word_freq_george, :word_freq_650, :word_freq_lab,
  #        :word_freq_labs, :word_freq_telnet, :word_freq_857, :word_freq_data, :word_freq_415, :word_freq_85, :word_freq_technology,
  #        :word_freq_1999, :word_freq_parts, :word_freq_pm, :word_freq_direct, :word_freq_cs, :word_freq_meeting, :word_freq_original,
  #        :word_freq_project, :word_freq_re, :word_freq_edu, :word_freq_table, :word_freq_conference,
  #        :char_freq_semicolon, #;
  #        :char_freq_open_parenthesis, #(
  #        :char_freq_open_brackets, #[
  #        :char_freq_!,
  #        :char_freq_dollar, #$
  #        :char_freq_number, ##
  #        :capital_run_length_average, :capital_run_length_longest, :capital_run_length_total, :spam ]

  # Returns the content of the CSV as hash of hashs. Each line is a hash
  hash = BayesSpamFilter.getSampleHashs #CSVParser.csv_to_hash
  training_hashes_size = (hash.size * 0.8).to_int

  puts "Choose the method:\n Type\n 1 to use the Bernoulli method\n 2 to use the Gaussian method and\n 3 to use Histogram Method."
  option = gets.chomp

  # User chooses the distribuction to generate the results
	if option != '1' and option != '2' and option != '3'
	  print("You need to enter 1, 2 or 3.")
	elsif option == '1'
		print "Using the Bernoulli Distribution to generate the results:"
	elsif option == '2'
		print "Using the Gaussian Distribution to generate the results"
	elsif option == '3'
		print "Using the Histogram Distribution to generate the results"
  end

  # Trains the algorithm
  BayesSpamFilter.train_algorithm(hash, training_hashes_size, distribuction_option)

end
