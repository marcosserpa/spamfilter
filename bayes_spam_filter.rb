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

  features = [ :word_freq_make, :word_freq_address, :word_freq_all, :word_freq_3d, :word_freq_our, :word_freq_over, :word_freq_remove,
               :word_freq_internet, :word_freq_order, :word_freq_mail, :word_freq_receive, :word_freq_will, :word_freq_people, :word_freq_report,
               :word_freq_addresses, :word_freq_free, :word_freq_business, :word_freq_email, :word_freq_you, :word_freq_credit, :word_freq_your,
               :word_freq_font, :word_freq_000, :word_freq_money, :word_freq_hp, :word_freq_hpl, :word_freq_george, :word_freq_650, :word_freq_lab,
               :word_freq_labs, :word_freq_telnet, :word_freq_857, :word_freq_data, :word_freq_415, :word_freq_85, :word_freq_technology,
               :word_freq_1999, :word_freq_parts, :word_freq_pm, :word_freq_direct, :word_freq_cs, :word_freq_meeting, :word_freq_original,
               :word_freq_project, :word_freq_re, :word_freq_edu, :word_freq_table, :word_freq_conference,
               :char_freq_semicolon, #;
               :char_freq_open_parenthesis, #(
               :char_freq_open_brackets, #[
               :char_freq_!,
               :char_freq_dollar, #$
               :char_freq_number, ##
               :capital_run_length_average, :capital_run_length_longest, :capital_run_length_total, :spam ]

  # creation of k fold
  #reads the spambase file and creates the k folds.
  #input is nothing, output are the groups.
  #contract -> (void) returns (list[list])
  def self.getSampleHashs
    #gets all the data from the spambase file and stores it in a dictionary
    #spam_base = File.read('spambase_2.csv')
    # csv = File.read('spambase_2.csv')
    # spam_base = CSV.new(csv, :converters => :all)
    # spam_base_array = spam_base.to_a
    puts "Type the CSV file name with the extension:"
    file_name = gets.chomp

    CSVParser.csv_to_hash(file_name)
  end

  # Training by Cross-Validation Technique - 2 randomly set sets
  #This function takes a number, and separates it from the total groups, creating a testing group and a training group.
  #Takes a set number to be excluded (iteration wise) and passed 2 lists : testing group and training group to the training function.
  #Based on the input option, calls the appropriate function.
  #contract -> (int,list[list],int) returns (void) ,like a main function for the entire 3 methods. calls the related functions with corresponding parameters.
  def self.train_algorithm(hash, training_hashes_size, distribuction_option)
    training_hashes_indexes = training_hashes_size.times.map{ 0 + rand(4601) }
    testing_hashes = hash.clone
    training_hashes = {}

    # separates training set from testing set
    training_hashes_indexes.each do |index|
      training_hashes[index] = testing_hashes.delete(index)
    end

    # training result by the method selected
  	if distribuction_option == 1
  		print "Results for Fold " , excludeSet
  		bernoulli_distribuction(training_hashes, testing_hashes)  #Runs Bernoulli Method.
  	elsif distribuction_option == 2
  		print "Results for Fold " , excludeSet
  		gaussianMethod(training_hashes, testing_hashes)	#Runs Gaussian Method.
  	elsif distribuction_option ==3
  		print "Results for Fold " , excludeSet
  		histogramMethod(training_hashes, testing_hashes) #Runs Histogram Method.
    end
  end

  #This function takes in the training and testing sets and performs the training/testing operations for bernoulli classifier and calcuates the error rate,tpr,fpr by calling helper functions.
  #input is the testing group and the training group of emails.
  #prints the error rate,false positive rate, false negative rate, and the area under the curve for a particular fold.
  #contract -> (list,list) returns (void), like the main function for the bernoulli method. Works by calling helper functions.
  def self.bernoulli_distribuction(training_set, testing_set)
  	$tprList
  	tprList = []
  	$fprList
  	fprList = []

  	spam_averages, not_spam_averages, spam_counter, not_spam_counter = calculates_averages(training_set)
  	general_averages = calculates_general_averages(training_set)
    spam_probability_minor_equal, spam_probability_more, not_spam_probability_minor_equal, not_spam_probability_more =
      calculates_probabilities(training_set, spam_counter, not_spam_counter, spam_averages, not_spam_averages)

  	probabilitiesCaseI,probabilitiesCaseII,probabilitiesCaseIII,probabilitiesCaseIV = normalizeTrainingSet(trainEmail,meanValues,spamCount,notSpamCount)
  	resultDict,scoreList = bernoulliCalculation(testingGroup,meanValues,probabilitiesCaseI,probabilitiesCaseII,probabilitiesCaseIII,probabilitiesCaseIV,spamCount,notSpamCount)
  	errorRate,actualDict,falsePositiveRate,falseNegativeRate = calculateErrorRate(testingGroup,resultDict)
  	getROCPoints(scoreList,actualDict,testingGroup)
  end

  # Calculates the conditional averages for the features in the training set discriminationg spam/not spam emails.
  # Input is the training set and returns the mean values hash and a list of emails.
  # Helper function called by all the 3 classifiers.
  # contract -> (list) returns (dict, dict, int,int)
  def self.calculates_averages(training_set)
  	train_email = []
  	spam_averages = {}
  	not_spam_averages = {}

    features.each do |feature|
      spam_counter = 0
      not_spam_counter = 0
      spam_feature_average = 0.0
      not_spam_feature_average = 0.0

      training_set.each do |email|
        if email[:spam] == 1
          spam_counter += 1
          spam_feature_average += email[feature]
        else
          not_spam_counter += 1
          not_spam_feature_average += email[feature]
        end
      end

      # Store the feature averages to spam and not spam mails
      spam_averages[feature] = spam_feature_average / spam_counter
      not_spam_averages[feature] = not_spam_feature_average / not_spam_counter
    end

    return [spam_averages, not_spam_averages, spam_counter, not_spam_counter]
  end

  # Calculates the training_set averages without spam/not discrimination.
  #takes as input the entire training set of emails.
  #returns a idctionary of mean values for all features of the training set.
  #contract -> (list) returns (dict)
  def self.calculates_general_avegares(training_set)
    general_averages = {}

    features.each do |iterator|
      general_averages[iterator] = 0
    end

    training_set.each do |email|
      features.each do |feature|
        general_averages[feature] += email[feature]
      end
    end

    features.each do |feature|
      general_averages[feature] /= training_set.size
    end

    general_averages
  end

  #Works with the training set and the mean values, classifying the email probabilities according to spam/not spam and feature/meanAverageValue comparison.
  # P(feature value <= average(feature) | spam)
  # P(feature value > average(feature) | spam)
  # P(feature value <= average(feature) | non-spam)
  # P(feature value > average(feature) | non-spam)
  #Takes training email list and mean values dictionary and returns 4 dictionaries of probabilities which are caclulated using the above formulae. It also returns the spam and ham count for the training set.
  #called by the naive bayes classisifer using bernoulli distribution.
  #contract -> (list,dict,int,int) returns (dict,dict,dict,dict)
  def self.calculates_probabilities(training_set, spam_counter, not_spam_counter, spam_averages, not_spam_avegares)
    spam_probability_minor_equal = {}
    spam_probability_more = {}
    not_spam_probability_minor_equal = {}
    not_spam_probability_more = {}

    features.each do |feature|
      spam_probability_minor_equal = 0.0
      spam_probability_more = 0.0
      not_spam_probability_minor_equal = 0.0
      not_spam_probability_more = 0.0
    end

    training_set.each do |email|
      features.each do |feature|
        if (email[feature] <=
      end
    end

  end

spam_probability_minor_equal, spam_probability_more, not_spam_probability_minor_equal, not_spam_probability_more =
  verifies_equality(spam_counter, not_spam_counter, spam_averages, not_spam_averages)
  def normalizeTrainingSet(trainEmail,meanValues,spamCount,notSpamCount):
  	probabilitiesCaseI = {}
  	probabilitiesCaseII = {}
  	probabilitiesCaseIII = {}
  	probabilitiesCaseIV = {}

  	for i in range(0,57):
  		probabilitiesCaseI[i] = 0.0
  		probabilitiesCaseII[i] = 0.0
  		probabilitiesCaseIII[i] = 0.0
  		probabilitiesCaseIV[i] = 0.0

  	for email in trainEmail:
  		email = email.split(',')

  		for feature in range(0,57):
  			if (float(email[feature])<=meanValues[feature]) and int(email[57])==1:
  				probabilitiesCaseI[feature] += 1
  			elif (float(email[feature])>meanValues[feature]) and int(email[57])==1:
  				probabilitiesCaseII[feature] += 1
  			elif (float(email[feature])<=meanValues[feature]) and int(email[57])==0:
  				probabilitiesCaseIII[feature] += 1
  			elif (float(email[feature])>meanValues[feature]) and int(email[57])==0:
  				probabilitiesCaseIV[feature] += 1

  	for i in range(0,57):
  		probabilitiesCaseI[i] = (probabilitiesCaseI[i]+1)/(float(spamCount) + 2)
  		probabilitiesCaseII[i] = (probabilitiesCaseII[i]+1)/(float(spamCount) + 2)
  		probabilitiesCaseIII[i] = (probabilitiesCaseIII[i]+1)/(float(notSpamCount) + 2)
  		probabilitiesCaseIV[i] = (probabilitiesCaseIV[i]+1)/(float(notSpamCount) + 2)

  	return probabilitiesCaseI,probabilitiesCaseII,probabilitiesCaseIII,probabilitiesCaseIV

end
