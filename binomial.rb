load 'interest_measurements.rb'
load 'math_extension.rb'

module Distribution
  class Binomial

    def self.pmf(events, successes, probability)
      raise "successes ir greater than  events (successes > events)" if successes > events
      puts "probabilidade #{Math.binomial_coefficient(events ,successes)*(probability**successes)*(1-probability)**(events- successes)}"
    end

    # probabilities is the array probabilities of all variables we want to calculate; events
    # is the array of the number of events ocurred of each variable
    def self.mean(probabilities, events)
      puts "média #{probabilities * events}"
    end

    def self.second_moment(probability, events)
      puts "segundo momento #{(probability * events)*(1-probability + (probability * events))}"
    end

  end
end
