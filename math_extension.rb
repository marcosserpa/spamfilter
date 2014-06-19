require 'bigdecimal'
require 'bigdecimal/math'
require 'prime'
require 'pry'

module MathExtension

  # Factorization based on Prime Swing algorithm, by Luschny ( the king of factorial numbers analysis :P )
  # == Reference
  # * The Homepage of Factorial Algorithms. (C) Peter Luschny, 2000-2010
  # == URL: http://www.luschny.de/math/factorial/csharp/FactorialPrimeSwing.cs.html
  class SwingFactorial

    attr_reader :result
    SmallOddSwing=[ 1, 1, 1, 3, 3, 15, 5, 35, 35, 315, 63, 693, 231, 3003, 429, 6435, 6435, 109395, 12155, 230945, 46189, 969969, 88179, 2028117, 676039, 16900975, 1300075, 35102025, 5014575,145422675, 9694845, 300540195, 300540195]
    SmallFactorial=[1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800, 39916800, 479001600, 6227020800, 87178291200, 1307674368000, 20922789888000, 355687428096000, 6402373705728000, 121645100408832000, 2432902008176640000]
    def bitcount(n)
      bc = n - ((n >> 1) & 0x55555555);
      bc = (bc & 0x33333333) + ((bc >> 2) & 0x33333333);
      bc = (bc + (bc >> 4)) & 0x0f0f0f0f;
      bc += bc >> 8;
      bc += bc >> 16;
      bc = bc & 0x3f;
      bc
    end
    def initialize(n)
      if (n<20)
        @result=SmallFactorial[n]
        #naive_factorial(n)
      else
      @prime_list=[]
      exp2 = n - bitcount(n);
      @result= recfactorial(n)<< exp2
      end
    end
    def recfactorial(n)
      return 1 if n<2
      (recfactorial(n/2)**2) * swing(n)
    end
    def swing(n)
      return SmallOddSwing[n] if (n<33)
      sqrtN = Math.sqrt(n).floor
      count=0

      Prime.each(n/3) do |prime|
        next if prime<3
        if (prime<=sqrtN)
          q=n
          _p=1

          while((q=(q/prime).truncate)>0) do
            if((q%2)==1)
              _p*=prime
            end
          end
          if _p>1
            @prime_list[count]=_p
            count+=1
          end

        else
          if ((n/prime).truncate%2==1)
            @prime_list[count]=prime
            count+=1
          end
        end
      end
      prod=get_primorial((n/2).truncate+1,n)
      prod * @prime_list[0,count].inject(1) {|ac,v| ac*v}
    end
    def get_primorial(low,up)
      prod=1;
      Prime.each(up) do |prime|
        next if prime<low
        prod*=prime
      end
      prod
    end
    def naive_factorial(n)
      @result=(self.class).naive_factorial(n)
    end
    def self.naive_factorial(n)
      (2..n).inject(1) { |f,nn| f * nn }
    end

  end

  # Binomial coeffients, or:
  # ( n )
  # ( k )
  #
  # Gives the number of *different* k size subsets of a set size n
  #
  # Uses:
  #
  #  (n)   n^k'    (n)..(n-k+1)
  #  ( ) = ---- =  ------------
  #  (k)    k!          k!
  #
  def binomial_coefficient(n,k)
    return 1 if (k==0 or k==n)
    k=[k, n-k].min
    binding.pry
    permutations(n,k).quo(factorial(k))
    # The factorial way is
    # factorial(n).quo(factorial(k)*(factorial(n-k)))
    # The multiplicative way is
    # (1..k).inject(1) {|ac, i| (ac*(n-k+i).quo(i))}
  end

  # Sequences without repetition. n^k'
  # Also called 'failing factorial'
  def permutations(n,k)
    binding.pry
    return 1 if k==0
    return n if k==1
    return factorial(n) if k==n
    (((n-k+1)..n).inject(1) {|ac,v| ac * v})
    #factorial(x).quo(factorial(x-n))
  end

  # Exact factorial.
  # Use lookup on a Hash table on n<20
  # and Prime Swing algorithm for higher values.
  def factorial(n)
    binding.pry
    SwingFactorial.new(n).result
  end

  #module_function :binomial_coefficient, :permutations, :factorial

end

module Math
  include MathExtension
  module_function :binomial_coefficient, :permutations, :factorial
end
