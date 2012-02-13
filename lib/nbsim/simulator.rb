module Nbsim

# This class does the n-body simulation (force
# prop. to 1/r^2) for you, depending on the given
# initializing parameters.
# Core algorithm of the numerical calculations
# is the so called 'Verlet Algorithm'.
#
class Simulator
	G = 20		# Gravitational constant
	H = 0.1		# Step size
	THRESHOLD = 100	# Maximum square distance, where force stays constant (because of numerical divergences)

	# Initializes the simulator, with following parameters:
	#
	# [data]	Expects a +Nbsim::Database+ object.
	# 		Obviously the initial conditions should be set, otherwise the
	# 		simulators output will be the trivial solutions.
	# 		This data object gets manipulated by the simulator.
	# 
	#def initialize(data)
#
#		@data = data
#
#		simulate
#		return @data
#	end


	# Starts the actual calculations and returns an 2d data array.
	# (same format as initial conditions but with #+timesteps+ entries.
	#
	# = Code Logic
	# u ... data matrix (accessible till i)
	# t ... time
	# j ... degree of freedom
	# 
	# the formula for function f, where u'' = f(u,i,j)
	# for a gravitational force (1/r^2) acting on each other is
	#
	# f_j = - G * Sum(over l) m_l * (q_j-q_3k+l) * 1/r_zl^(3/2)
	# where k = j div (number of particles)
	# and z = j mod (number of particles)
	# and l = set of particle-indices without z
	# and q0,q1,q2,q3,q4,q5, ... = x1,x2,x3,y1,y2,y3,...
	# r_zl = sum(over particle indices) (q_3i+z-q_3i+l)^2 is
	# the square distance between two interacting particles
	# 
	# [data]	Expects a +Nbsim::Database+ object.
	# 		Obviously the initial conditions must be set, otherwise the
	# 		simulators output will be not of use (distance of particles=0)
	# 		This data object gets manipulated by the simulator.
	#
	def self.do(data)
		@@data = data

		# Verlet Algorithm:
		# u(t+1) = 2u(t) − u(t−1) + h^2 f(t(i) , u(i))

		(1..@@data.timesteps-2).each do |t|
			(0..@@data.dof*@@data.n-1).each do |j|
				@@data[t+1][j] = 2 * @@data[t][j] - @@data[t-1][j] + ( f(t,j) * H**2)
			end
		end
	end


private

	def self.f(t,j)
		
		k = j/@@data.n
		z = j.modulo(@@data.n)

		res = 0
		(0..@@data.n-1).each do |l|
			res -= (@@data.mass(l) * (@@data[t][j] - @@data[t][@@data.n*k+l])) / ( r(t,z,l) ** (1)) unless l == z
		end

		return G*res
	end

	def self.r(t,k,l)
		
		res = 0
		(0..@@data.dof-1).each do |i|
			res += (@@data[t][@@data.n*i+k] - @@data[t][@@data.n*i+l]) ** 2
		end

		if res < THRESHOLD
			res = THRESHOLD
		end

		return res
	
	end

end

end
