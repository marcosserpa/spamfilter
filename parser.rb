require 'csv'

# Read the CSV - already with the features names at the begining - and parses it into a hash
class CSVParser

  # Parse CSV to hash
  def self.csv_to_hash(file_name = '')
    if file_name.empty?
      raise "Give the name of .csv."
    end

    body = File.read(file_name)

    # Hashing CSV
    csv = CSV.new(body, :headers => true, :header_converters => :symbol, :converters => :all)
    hash = csv.to_a.map! {|row| row.to_hash }

    enumerate_hash(hash)
  end

  # Enumerates the CSV hash
  def self.enumerate_hash(csv)
    indexed_hash = {}
    iterator = 0

    csv.each do |item|
      indexed_hash[iterator] = item
      iterator = iterator + 1
    end

    indexed_hash
  end

end
