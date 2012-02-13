module Nbsim

# This class respresents the main window of
# the qt gui part.
# 
class Main_qt < Qt::Widget

	def initialize
		super

		# create data
		timesteps = 10000
		n = 3
		dof = 2
		 
		data = Nbsim::Database.new(timesteps, n, dof)
		#data.set_init_cond(0, [100, -90, 0])
		#data.set_init_cond(1, [300, -40, 0])
		#data.set_init_cond(2, [0, 0, 0])
		data.set_init_cond(0, [100, -90])
		data.set_init_cond(1, [300, -40])
		data.set_init_cond(2, [0, 0])
		data.set_mass(0, 1)
		data.set_mass(1, 5)
		data.set_mass(2, 8)
		 
		Nbsim::Simulator.do(data)

		@visualizer = Nbsim::Visualizer_qt.new(self,data)

		layout = Qt::VBoxLayout.new
		layout.add_widget(@visualizer)

		self.set_layout(layout)

	end

end

end
