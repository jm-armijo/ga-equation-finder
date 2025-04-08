require 'rspec'
require 'ga'
require 'equation'

RSpec.describe GA do
  let(:mock_equation) { instance_double("Equation") }

  before do
    allow(Equation).to receive(:new).and_return(*Array.new(10) { mock_equation })

    fitness_values = [10.0, 8.0, 6.0, 4.0, 3.0, 2.5, 2.0, 1.5, 1.0, 0.005]
    allow(mock_equation).to receive(:fitness) { fitness_values.shift || 0.005 }

    allow(mock_equation).to receive(:crossover).and_return(mock_equation)
    allow(mock_equation).to receive(:mutate).and_return(mock_equation)
  end

  describe '#initialize' do
    it 'sets population size and generations' do
      ga = GA.new(20, 30)
      expect(ga.instance_variable_get(:@population_size)).to eq(20)
      expect(ga.instance_variable_get(:@generations)).to eq(30)
    end
  end

  describe '#run' do
    it 'returns the equation with the lowest fitness' do
      ga = GA.new(10, 50)
      result = ga.run
      expect(result).to eq(mock_equation)
    end

    it 'stops early if a solution has fitness < 0.01' do
      ga = GA.new(10, 100)
      expect(mock_equation).to receive(:fitness).at_least(:once)
      result = ga.run
      expect(result.fitness).to be < 0.01
    end

    it 'fills new_population using crossover and mutate' do
      ga = GA.new(6, 3)

      expect(mock_equation).to receive(:crossover).at_least(:once)
      expect(mock_equation).to receive(:mutate).at_least(:once)

      ga.run
    end
  end
end
