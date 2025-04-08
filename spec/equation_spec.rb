# spec/equation_solver/equation_spec.rb
require 'rspec'
require 'equation'

RSpec.describe EquationSolver::Equation do
  describe '#initialize' do
    it 'initializes with random structure and coefficients if none provided' do
      equation = described_class.new
      expect(equation.coefficients).to all(be_a(Float))
    end

    it 'initializes with given structure and coefficients' do
      structure = EquationSolver::Equation::STRUCTURES.find { |s| s[:name] == 'Quadratic' }
      coefficients = [1.0, 2.0, 3.0]
      equation = described_class.new(structure, coefficients)

      expect(equation.coefficients).to eq(coefficients)
      expect(equation.structure).to eq(structure[:func])
    end
  end

  describe '#evaluate' do
    it 'evaluates the equation with given x input' do
      structure = EquationSolver::Equation::STRUCTURES.find { |s| s[:name] == 'Quadratic' }
      coefficients = [1.0, 0.0, 0.0] # y = 1
      equation = described_class.new(structure, coefficients)

      expect(equation.evaluate(10)).to eq(1.0)
    end

    it 'ensures result is at least 0.0001' do
      structure = EquationSolver::Equation::STRUCTURES.find { |s| s[:name] == 'Quadratic' }
      coefficients = [-100.0, 0.0, 0.0]
      equation = described_class.new(structure, coefficients)

      expect(equation.evaluate(0)).to eq(0.0001)
    end
  end

  describe '#fitness' do
    it 'calculates fitness as total error against target values' do
      structure = EquationSolver::Equation::STRUCTURES.find { |s| s[:name] == 'Quadratic' }
      coefficients = [0.0, 0.0, 0.0] # y = 0
      equation = described_class.new(structure, coefficients)

      expected_error = EquationSolver::TARGET_VALUES.values.sum
      expect(equation.fitness).to be_within(0.1).of(expected_error)
    end
  end

  describe '#mutate' do
    it 'returns a new Equation with possibly changed coefficients' do
      structure = EquationSolver::Equation::STRUCTURES.find { |s| s[:name] == 'Quadratic' }
      coefficients = [1.0, 2.0, 3.0]
      equation = described_class.new(structure, coefficients)

      mutated = equation.mutate

      expect(mutated).to be_a(described_class)
      expect(mutated.coefficients.size).to eq(coefficients.size)
      expect(mutated.structure).to eq(equation.structure)
    end
  end

  describe '#crossover' do
    it 'returns a new Equation mixing coefficients from both parents' do
      structure = EquationSolver::Equation::STRUCTURES.find { |s| s[:name] == 'Quadratic' }
      a = described_class.new(structure, [1.0, 2.0, 3.0])
      b = described_class.new(structure, [4.0, 5.0, 6.0])

      child = a.crossover(b)

      expect(child).to be_a(described_class)
      expect(child.coefficients.size).to eq(3)
      expect(child.structure).to eq(a.structure)
    end
  end

  describe '#to_s' do
    it 'returns string representation of the equation' do
      structure = EquationSolver::Equation::STRUCTURES.find { |s| s[:name] == 'Quadratic' }
      coefficients = [1.0, 2.0, 3.0]
      equation = described_class.new(structure, coefficients)

      expect(equation.to_s).to eq('y = 1.0 + 2.0x + 3.0x^2')
    end
  end
end
