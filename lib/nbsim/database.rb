module Nbsim

# The class +Nbsim::Database+ respresents a datafile gathered by +Nbsim::Simulator+
# and provides a convinient way for accessing the simulated data.
#
class Database

	# Initializes the data respresentation with following needed parameters
	#
	# [timesteps]	Sets the number of timesteps the data should contain.
	# 		This must be at least 2.
	#
	# [n_particles]	Sets the number of used particles in the system.
	#
	# [dof]		Sets the number of Degrees Of Freedom. (3 for a 3D-space)
	#
	def initialize(timesteps, n_particles, dof)

		raise ArgumentError("The number of timesteps must at least be 2.") unless timesteps > 2

		@timesteps = timesteps
		@n = n_particles
		@dof = dof
		
		# data format is
		# +[x_1,x_2,...,x_n,y_1,...,y_n,z_1,...,z_n](t1)[...](t2)+
		@data = Array.new(@timesteps) { Array.new(@dof * @n) {0.0} }

		# default the particle masses to 1
		@m = Array.new(@n) {0.0}

	end

	# Sets the initial (carthesian) coordinates for a particle
	# identified by its number, so
	#
	# [particle]	Selects, which particle's coordinates are set.
	# 		The allowed range is 0 to the number of particles set
	# 		in +Database.new+ minus 1.
	#
	# [vec]		Expects an array of initial (carthesian) coordinates for the particle.
	# 		The array's dimension must be as the number of degrees of freedom
	# 		given in +Database.new+
	#
	# The initial conditions are set, so that the initial velocity is zero.
	def set_init_cond(particle, vec)

		raise ArgumentError("Particle identifier must be wrong.") unless (0..@n-1).include? particle
		raise ArgumentError("Position vector has wrong dimension.") unless vec.length == @dof

		# see data format
		(0..@dof).each { |i| @data[0][i*@dof+particle] = vec[i].to_f; }

		# init velocity = zero
		@data[1] = @data[0]
	end

	# Sets the mass for a particle
	# identified by its number,
	#
	# [particle]	Selects, which particle's coordinates are set.
	# 		The allowed range is 0 to the number of particles set
	# 		in +Database.new+ minus 1.
	#
	# [mass]	Excepts a Numeric, which represents the mass for the particle
	#
	def set_mass(particle, mass)
		raise ArgumentError("Particle identifier must be wrong.") unless (0..@n-1).include? particle

		@m[particle] = mass
	end


	# Gets an array of length of the number of degrees of freedom set in +Database.new+.
	# with the coordinates from a specific particle in a specific time.
	#
	# [particle]	Selects the particle.
	# 		The allowed range is 0 to the number of particles set
	# 		in +Database.new+ minus 1.
	#
	# [time]	Selects the time.
	# 		The allowed range is 0 to to the number of timesteps
	# 		set in +Database.new+ minus 1.
	#
	def get_coords(particle, time)
		(0..@dof-1).map do |i|
			@data[time][@dof*i + particle]
		end
	end


	# Returns the number of timesteps represented by this data object.
	#
	def timesteps; @timesteps; end

	# Returns the number of particles represented by this data object.	
	#
	def n; @n; end

	# Returns the number of degrees of freedom respresnted by this data object.
	#
	def dof; @dof; end

	# Returns the mass of a particle identified by the parameter +particle+.
	#
	def mass(particle); @m[particle]; end

	# Allow direct access to the data array.
	#
	def [](i); @data[i]; end

	def to_s
		@data.to_s
	end

end

end
