require 'equation'

class GA
  def initialize(population_size, generations)
    @population_size = population_size
    @generations = generations
  end

  def run
    population = Array.new(@population_size) { Equation.new }

    @generations.times do
      population.sort_by!(&:fitness)
      break if population.first.fitness < 0.01

      new_population = population.first(@population_size / 2)

      while new_population.size < @population_size
        parent1, parent2 = new_population.sample(2)
        child = parent1.crossover(parent2).mutate
        new_population << child
      end

      population = new_population
    end

    population.min_by(&:fitness)
  end
end
