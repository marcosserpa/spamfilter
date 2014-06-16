require 'pry'
load 'parser.rb'

#'main' function
# if __FILE__ == $0
#   binding.pry
#   getKFolds
#
#   # your code
# end


class BayesSpamFilter

  $features = [ :word_freq_make, :word_freq_address, :word_freq_all, :word_freq_3d, :word_freq_our, :word_freq_over, :word_freq_remove,
               :word_freq_internet, :word_freq_order, :word_freq_mail, :word_freq_receive, :word_freq_will, :word_freq_people, :word_freq_report,
               :word_freq_addresses, :word_freq_free, :word_freq_business, :word_freq_email, :word_freq_you, :word_freq_credit, :word_freq_your,
               :word_freq_font, :word_freq_000, :word_freq_money, :word_freq_hp, :word_freq_hpl, :word_freq_george, :word_freq_650, :word_freq_lab,
               :word_freq_labs, :word_freq_telnet, :word_freq_857, :word_freq_data, :word_freq_415, :word_freq_85, :word_freq_technology,
               :word_freq_1999, :word_freq_parts, :word_freq_pm, :word_freq_direct, :word_freq_cs, :word_freq_meeting, :word_freq_original,
               :word_freq_project, :word_freq_re, :word_freq_edu, :word_freq_table, :word_freq_conference,
               :char_freq_semicolon, #;
               :char_freq_open_parenthesis, #(
               :char_freq_open_brackets, #[
               :char_freq_exclamation, #!
               :char_freq_dollar, #$
               :char_freq_number, ##
               :capital_run_length_average, :capital_run_length_longest, :capital_run_length_total, :spam ]

  def self.getSampleHashs
    # csv = File.read('spambase_2.csv')
    # spam_base = CSV.new(csv, :converters => :all)
    # spam_base_array = spam_base.to_a
    puts "Type the CSV file name with the extension:"
    file_name = gets.chomp

    CSVParser.csv_to_hash(file_name)
  end

  # Training by Cross-Validation Technique - 2 randomly set sets
  def self.train_algorithm(hash, training_hashes_size, distribution_option, features_quantity)
    training_hashes_indexes = training_hashes_size.times.map{ 0 + rand(4601) }
    testing_hashes = hash.clone
    training_hashes = {}

    # Choose randomly the features, if not all
    unless features_quantity == 'all'
      features_indexes = features_quantity.times.map{ 0 + rand(57) }
      feats = []

      features_indexes.each do |index|
        feats << $features[index]
      end

      puts "Randomly choosen features:"
      feats.each do |f|
        puts f
      end

      $features = feats
    end

    # Separates training set from testing set
    training_hashes_indexes.each do |index|
      training_hashes[index] = testing_hashes.delete(index)
    end

    # Training result by the method selected
    puts ""
    puts "-------"
    puts ""

  	if (distribution_option == '1')
  		puts "Results for Bernoulli Distribuction"
  		bernoulli_distribution(training_hashes, testing_hashes)  #Runs Bernoulli Method.
    end
  end

  # This function takes in the training and testing sets and performs the training/testing operations for bernoulli classifier and calcuates the error rate,tpr,fpr by calling helper functions.
  def self.bernoulli_distribution(training_set, testing_set)
  	spam_averages, not_spam_averages, spam_counter, not_spam_counter = calculates_averages(training_set)

  	general_averages = calculates_general_averages(training_set)

    spam_probability_minor_equal, spam_probability_more, not_spam_probability_minor_equal, not_spam_probability_more =
      calculates_probabilities(training_set, general_averages, spam_counter, not_spam_counter, spam_averages, not_spam_averages)

    averages_and_variances = calculates_bernoulli_averages_and_variances(testing_set,
      general_averages, spam_counter, not_spam_counter, spam_probability_minor_equal, spam_probability_more,
      not_spam_probability_minor_equal, not_spam_probability_more)
    binding.pry
  end

  # Calculates the conditional averages for the features in the training set discriminationg spam/not spam emails.
  def self.calculates_averages(training_set)
  	spam_averages = {}
  	not_spam_averages = {}
    spam_counter = 0
    not_spam_counter = 0
    spam_feature_average = 0.0
    not_spam_feature_average = 0.0

    $features.each do |feature|
      spam_counter = not_spam_counter = 0
      spam_feature_average = not_spam_feature_average = 0.0

      training_set.each do |email|
        unless email[1].nil?
          if email[1][:spam] == 1
            spam_counter += 1
            spam_feature_average += email[1][feature]
          else
            not_spam_counter += 1
            not_spam_feature_average += email[1][feature]
          end
        end
      end

      # Store the feature averages to spam and not spam mails
      spam_averages[feature] = spam_feature_average / spam_counter
      not_spam_averages[feature] = not_spam_feature_average / not_spam_counter
    end

    puts "The averages to each situation and each feature is:"
    puts "When email is spam"
    spam_averages.each do |feature|
      puts "#{feature[0]}: #{feature[1]}"
    end
    puts ""
    puts "----------"
    puts ""
    puts "When email is not a spam"
    not_spam_averages.each do |feature|
      puts "#{feature[0]}: #{feature[1]}"
    end

    return [spam_averages, not_spam_averages, spam_counter, not_spam_counter]
  end

  # Calculates the training_set averages without spam/not discrimination.
  def self.calculates_general_averages(training_set)
    general_averages = {}

    $features.each do |feature|
      general_averages[feature] = 0.0
    end

    training_set.each do |email|
      unless email[1].nil?
        $features.each do |feature|
          general_averages[feature] += email[1][feature]
        end
      end
    end

    $features.each do |feature|
      general_averages[feature] /= training_set.size
    end

    general_averages
  end

  # Classify the email probabilities according to spam/not spam and feature/meanAverageValue comparison.
  # P(feature value <= average(feature) | spam)
  # P(feature value > average(feature) | spam)
  # P(feature value <= average(feature) | non-spam)
  # P(feature value > average(feature) | non-spam)
  def self.calculates_probabilities(training_set, general_averages, spam_counter, not_spam_counter, spam_averages, not_spam_avegares)
    spam_probability_minor_equal = {}
    spam_probability_more = {}
    not_spam_probability_minor_equal = {}
    not_spam_probability_more = {}

    $features.each do |feature|
      spam_probability_minor_equal[feature] = 0.0
      spam_probability_more[feature] = 0.0
      not_spam_probability_minor_equal[feature] = 0.0
      not_spam_probability_more[feature] = 0.0
    end

    training_set.each do |email|
      unless email[1].nil?
        $features.each do |feature|
          if ((email[1][feature] <= general_averages[feature]) and (email[1][:spam] == 1))
            spam_probability_minor_equal[feature] += 1.0
          elsif ((email[1][feature] > general_averages[feature]) and (email[1][:spam] == 1))
            spam_probability_more[feature] += 1.0
          elsif ((email[1][feature] <= general_averages[feature]) and (email[1][:spam] == 0))
            not_spam_probability_minor_equal[feature] += 1.0
          elsif ((email[1][feature] > general_averages[feature]) and (email[1][:spam] == 0))
            not_spam_probability_more[feature] += 1.0
          end
        end
      end
    end

    $features.each do |feature|
      spam_probability_minor_equal[feature] = (spam_probability_minor_equal[feature] + 1) / (spam_counter + 2)
      spam_probability_more[feature] = (spam_probability_more[feature] + 1) / (spam_counter + 2)
      not_spam_probability_minor_equal[feature] = (not_spam_probability_minor_equal[feature] + 1) / (not_spam_counter + 2)
      not_spam_probability_more[feature] = (not_spam_probability_more[feature] + 1) / (not_spam_counter + 2)
    end

    # TODO Imprimir na tela todas as pribabilidades e as médias de acordo com as mesmas.
    return [ spam_probability_minor_equal, spam_probability_more, not_spam_probability_minor_equal, not_spam_probability_more ]
  end

  # Uses the testing/training sets, the probabilities, spam and not spam counters (for the training set) and predicts if is spam or not for the testing set.
  def self.calculates_bernoulli_averages_and_variances(testing_set, general_averages, spam_counter, not_spam_counter, spam_probability_minor_equal, spam_probability_more, not_spam_probability_minor_equal, not_spam_probability_more)
  	averages_and_variances = Hash.new{
                                      |hash, feature| hash[feature] = Hash.new{
                                      |ha, spam_or_not| ha[spam_or_not] = Hash.new{
                                      |h, average_variance| h[average_variance] = [] } } }

    $features.each do |feature|
      averages_and_variances[feature][:spam][:average] = spam_probability_minor_equal[feature]
      averages_and_variances[feature][:spam][:variance] = spam_probability_minor_equal[feature] * (1 - spam_probability_minor_equal[feature])
      averages_and_variances[feature][:not_spam][:average] = not_spam_probability_minor_equal[feature]
      averages_and_variances[feature][:not_spam][:variance] = not_spam_probability_minor_equal[feature] * (1 - not_spam_probability_minor_equal[feature])
    end

    $features.each do |feature|
      puts  "Feature #{feature}: When spam, average and variance are, respectively, #{averages_and_variances[feature][:spam][:average]},
            #{averages_and_variances[feature][:spam][:variance]}. When not spam, average and variance are, respectively,
            #{averages_and_variances[feature][:not_spam][:average]}, #{averages_and_variances[feature][:not_spam][:variance]}."
    end

    binding.pry
#   	scores = []
#
#     testing_set.each do |iterator|
#       $features.each do |feature|
#         averages_and_variances[feature] = 1
#       end
#     end
#
#     probability_constant = Math.log(spam_counter / not_spam_counter)
#     counter = 0
#
#     testing_set.each do |email|
#       unless email[1].nil?
#         variant_probability = 0
#
#         $features.each do |feature|
#           #binding.pry
#           if ((email[1][feature] <= general_averages[feature]) and (email[1][feature] <= general_averages[feature]))
#             variant_probability += Math.log(spam_probability_minor_equal[feature] / not_spam_probability_minor_equal[feature])
#           elsif ((email[1][feature] <= general_averages[feature]) and (email[1][feature] > general_averages[feature]))
#             variant_probability += Math.log(spam_probability_minor_equal[feature] / not_spam_probability_more[feature])
#           elsif ((email[1][feature] > general_averages[feature]) and (email[1][feature] <= general_averages[feature]))
#             variant_probability += Math.log(spam_probability_more[feature] / not_spam_probability_minor_equal[feature])
#           else
#             variant_probability += Math.log(spam_probability_more[feature] / not_spam_probability_more[feature])
#           end
#         end
#
#         score = probability_constant + variant_probability
#
#         if score < 0
#           averages_and_variances[counter] = 0
#         end
#
#         counter += 1
#         scores << score
#       end
#     end
# binding.pry
#     return [averages_and_variances, scores]

    averages_and_variances
  end

end
