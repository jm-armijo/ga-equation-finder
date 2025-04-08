# frozen_string_literal: true

module EquationSolver
  TARGET_VALUES = {
    0 => 0,
    0.91 => 90,
    0.46 => 26,
    0.37 => 12.2
  }.freeze

  MUTATION_RATE = 0.05

  class Equation
    attr_reader :coefficients, :structure

    STRUCTURES = [
      {name: "Quadratic", func: ->(x, c) { c[0] + c[1] * x + c[2] * x**2 }, coeffs: 3},
      {name: "Exponential", func: ->(x, c) { c[0] * Math.exp(c[1] * x) }, coeffs: 2},
      {name: "Cubic", func: ->(x, c) { c[0] + c[1] * x + c[2] * x**2 + c[3] * x**3 }, coeffs: 4},
      {name: "Fourier", func: ->(x, c) { c[0] + c[1] * Math.sin(c[2] * x) + c[3] * Math.cos(c[4] * x) }, coeffs: 5}
    ]

    def initialize(structure = nil, coefficients = nil)
      chosen = structure || STRUCTURES.sample
      @name = chosen[:name]
      @structure = chosen[:func]
      @coefficients = coefficients || Array.new(chosen[:coeffs]) { rand(-5.0..5.0) }
    end

    def evaluate(x)
      [@structure.call(x, @coefficients), 0.0001].max # Ensure output > 0
    end

    def fitness
      total_error = 0.0
      penalty = 0.0

      TARGET_VALUES.each do |input, expected_output|
        actual_output = evaluate(input)
        error = (actual_output - expected_output).abs
        total_error += error
        penalty += 1.0 if actual_output < 0
      end

      total_error + penalty * 1000
    end

    def mutate
      new_coeffs = @coefficients.map { |c| (c.nil? ? rand(-5.0..5.0) : c) + ((rand < MUTATION_RATE) ? rand(-1.0..1.0) : 0) }
      Equation.new(STRUCTURES.find { |s| s[:func] == @structure }, new_coeffs)
    end

    def crossover(other)
      new_coeffs = @coefficients.zip(other.coefficients).map { |a, b|
        if rand < 0.5
          a.nil? ? rand(-5.0..5.0) : a
        else
          (b.nil? ? rand(-5.0..5.0) : b)
        end
      }
      Equation.new(STRUCTURES.find { |s| s[:func] == @structure }, new_coeffs)
    end

    def to_s
      case @name
      when "Quadratic"
        "y = #{@coefficients[0]} + #{@coefficients[1]}x + #{@coefficients[2]}x^2"
      when "Exponential"
        "y = #{@coefficients[0]} * e^(#{@coefficients[1]}x)"
      when "Cubic"
        "y = #{@coefficients[0]} + #{@coefficients[1]}x + #{@coefficients[2]}x^2 + #{@coefficients[3]}x^3"
      when "Fourier"
        "y = #{@coefficients[0]} + #{@coefficients[1]}sin(#{@coefficients[2]}x) + #{@coefficients[3]}cos(#{@coefficients[4]}x)"
      else
        "Unknown equation type"
      end
    end
  end
end

include EquationSolver
