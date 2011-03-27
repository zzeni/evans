require 'open3'

class TestRunner
  attr_reader :passed_count, :failures_count, :log

  def initialize(test, solution)
    @test = test
    @solution = solution
  end

  def run
    ENV['PYTHONPATH'] = Rails.root.join("python")

    solution_path = make_temp_file(@solution, 'solution')
    test_path = make_temp_file(@test, 'test')

    Open3.popen3("python3.2", test_path, solution_path) do |stdin, stdout, stderr|
      load_log stdout.read + stderr.read
    end
  end

  private

  def make_temp_file(code, name)
    file = Tempfile.new(name)
    file.write code
    file.close
    file.path
  end

  def load_log(output)
    if /\A(\d+) (\d+)\n/ =~ output
      @passed_count, @failures_count = [$1, $2].map(&:to_i)
      @log = $'
    else
      @passed_count, @failures_count = 0, 0, 0
      @log = output
    end
  end
end
