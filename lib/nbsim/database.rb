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
		check_particle(particle)
		check_dimension(vec)

		# see data format
		(0..@dof-1).each { |i| @data[0][i*@n+particle] = vec[i].to_f }

		# init velocity = zero
		@data[1] = @data[0].clone
	end

	# Sets the initial (carthesian) velocities for a particle
	# identified by its number, so
	#
	# [particle]	Selects, which particle's coordinates are set.
	# 		The allowed range is 0 to the number of particles set
	# 		in +Database.new+ minus 1.
	#
	# [vec]		Expects an array of initial (carthesian) velocity components
	# 		for the particle. The array's dimension must be as the number
	# 		of degrees of freedom given in +Database.new+
	#
	def set_init_velo(particle, vec)
		check_particle(particle)
		check_dimension(vec)

		(0..@dof-1).each do |i|
			@data[1][i*@n+particle] = @data[0][i*@n+particle] + vec[i].to_f
		end
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
		check_particle(particle)

		@m[particle] = mass
	end


	# Returns an array of length of the number of degrees of freedom set in +Database.new+
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
		check_particle(particle)
		check_time(time)

		(0..@dof-1).map do |i|
			@data[time][@n*i + particle]
		end
	end

	# Returns an array of length of the number of degrees of freedom set in +Database.new+
	# with the coordinates of the center of mass in a specific time.
	#
	# [time]	Selects the time.
	# 		The allowed range is 0 to to the number of timesteps
	# 		set in +Database.new+ minus 1.
	#
	def get_center_of_mass(time)
		check_time(time)

		m = @m.inject(:+)
		pvs = (0..@n-1).map { |i| self.get_coords(i,time) }

		(0..@dof-1).map do |q|
			(0..@n-1).inject(0) {|sum,n| sum + @m[n] * pvs[n][q]} / m
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

private

	def check_time(time)
		raise ArgumentError.new("Time (#{time}) not in range of data.") unless (0..@timesteps-1).include? time
	end

	def check_particle(particle)
		raise ArgumentError.new("Particle identifier (#{particle}) must be wrong.") unless (0..@n-1).include? particle
	end	

	def check_dimension(vec)
		raise ArgumentError.new("Position vector (#{vec}) has wrong dimension.") unless vec.length == @dof
	end

end

end
