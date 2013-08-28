module ModelStats
  # class-wide statistics methods
  module ClassMethods
    def average(attr, options = {})
      if column_names.include?(attr.to_s)
        super
      else
        all(options).collect(&attr).average
      end
    end

    alias_method :mean, :average

    def median(attr, options = {})
      all(options).collect(&attr).median
    end

    def mode(attr, options = {})
      all(options).collect(&attr).mode
    end

    def sum(attr, options = {})
      if column_names.include?(attr.to_s)
        super
      else
        all(options).collect(&attr).sum
      end
    end

    def range(attr, options = {})
      all(options).collect(&attr).range
    end

    def standard_deviation(attr, options = {})
      all(options).collect(&attr).standard_deviation || 0
    end

    def variance(attr, options = {})
      all(options).collect(&attr).variance
    end

    alias_method :dispersion, :variance

    def weighted_moving_average(attr, options = {})
      all(options).collect(&attr).weighted_moving_average
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  # element's deviation by:
  #   mean (default)
  #   median
  #   mode
  def deviation(attr, by = :mean, options = {})
    (self.send(attr) - self.class.send(by, attr, options)).abs
  end
end