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
  		training(testingGroup,trainingGroup)  #Runs Bernoulli Method.
  	elsif distribuction_option == 2
  		print "Results for Fold " , excludeSet
  		gaussianMethod(testingGroup,trainingGroup)	#Runs Gaussian Method.
  	elsif distribuction_option ==3
  		print "Results for Fold " , excludeSet
  		histogramMethod(testingGroup,trainingGroup) #Runs Histogram Method.
    end
  end

end
