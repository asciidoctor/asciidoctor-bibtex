
module AsciidocBib
  module ProcessorUtils
    # Used with numeric styles to combine consecutive numbers into ranges
    # e.g. 1,2,3 -> 1-3, or 1,2,3,6,7,8,9,12 -> 1-3,6-9,12
    # leave references with page numbers alone
    def combine_consecutive_numbers str
      nums = str.split(",").collect(&:strip)
      res = ""
      # Loop through ranges
      start_range = 0
      while start_range < nums.length do
        end_range = start_range
        while (end_range < nums.length-1 and
               nums[end_range].is_i? and
               nums[end_range+1].is_i? and
               nums[end_range+1].to_i == nums[end_range].to_i + 1) do
                 end_range += 1
               end
               if end_range - start_range >= 2
                 res += "#{nums[start_range]}-#{nums[end_range]}, "
               else
                 start_range.upto(end_range) do |i|
                   res += "#{nums[i]}, "
                 end
               end
               start_range = end_range + 1
        end
        # finish by removing last comma
        res.gsub(/, $/, '')
      end
    end
  end
#end # TODO: why not needed?

