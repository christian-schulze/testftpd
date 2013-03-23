require 'simplecov-rcov'

class SimpleCov::Formatter::HTMLFormatter
  def output_path
    File.join(SimpleCov.coverage_path, 'html')
  end
end

class SimpleCov::Formatter::MergedFormatter
  def format(result)
    SimpleCov::Formatter::HTMLFormatter.new.format(result)
    SimpleCov::Formatter::RcovFormatter.new.format(result)
  end
end

SimpleCov.start do
  add_filter '/spec/'
  maximum_coverage_drop 1
  minimum_coverage 85
  formatter SimpleCov::Formatter::MergedFormatter
end
