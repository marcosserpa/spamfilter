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
    puts "Type the the CSV file name with the extension:"
    file_name = gets.chomp

    CSVParser.csv_to_hash(file_name)
  end

  #This function takes a number, and separates it from the total groups, creating a testing group and a training group.
  #Takes a set number to be excluded (iteration wise) and passed 2 lists : testing group and training group to the training function.
  #Based on the input option, calls the appropriate function.
  #contract -> (int,list[list],int) returns (void) ,like a main function for the entire 3 methods. calls the related functions with corresponding parameters.
  def self.trainFolds(excludeSet,groups,option)
    trainingGroup = []
  	testingGroup = groups[excludeSet] # exclude the testing group

  	# for j in range(0,len(groups))
  	# 	if j != excludeSet:
  	# 		trainingGroup.append(groups[j])

  	if option == 1
  		print "Results for Fold " , excludeSet
  		training(testingGroup,trainingGroup)                    #Runs Bernoulli Method.
  	elsif option == 2
  		print "Results for Fold " , excludeSet
  		gaussianMethod(testingGroup,trainingGroup)	#Runs Gaussian Method.
  	elsif option ==3
  		print "Results for Fold " , excludeSet
  		histogramMethod(testingGroup,trainingGroup) #Runs Histogram Method.
    end
  end

end








# class Bayes
# # creation of k fold
#
#
# #reads the spambase file and creates the k folds.
# #input is nothing, output are the groups.
# #contract -> (void) returns (list[list])
# def self.getKFolds
#   #gets all the data from the spambase file and stores it in a dictionary
#   spam_base = File.read('spambase.data')
#   binding.pry
# # 	spambaseData = open('spambase.data','r').readlines()
# # 	spambase = {}
# # 	i = 1
# # 	for spamfile in spambaseData:
# # 		spambase[i] = spamfile.strip()
# # 		i += 1
# # #breaks the spambase dictonary into smaller chunks of sort {1,11,22,...} uptil {10,20,30,...}
# # 	groups = []
# # 	for k in range(1,11):
# # 		fold = []
# # 		fold.append(spambase[k])
# # 		j=k
# # 		while(j<4599):
# # 			if(j+10>4601):
# # 				break
# # 			else:
# # 				fold.append(spambase[j+10])
# # 				j += 10
# # 		groups.append(fold)
# # 	return groups
# end
# end
