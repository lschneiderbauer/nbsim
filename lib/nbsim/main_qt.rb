module Nbsim

# This class respresents the main window of
# the qt gui part.
# 
class Main_qt < Qt::Widget

	def initialize
		super

		# create data
		timesteps = 10000
		n = 4
		dof = 3
		 
		data = Nbsim::Database.new(timesteps, n, dof)
		data.set_init_cond(0, [0, 0,0])
		data.set_init_cond(1, [0, 100,0])
		data.set_init_cond(2, [0, 300,0])
		data.set_init_cond(3, [0, 500,0])
		#data.set_init_cond(4, [150,0,0])
		#data.set_init_cond(5, [-150,0,0])

		data.set_init_velo(0, [0,0,0])
		data.set_init_velo(1, [0,0,5])
		data.set_init_velo(2, [5,0,0])
		data.set_init_velo(3, [5,0,0])
		#data.set_init_velo(0, [-5,0,1])
		#data.set_init_velo(1, [5,0,1])
		#data.set_init_velo(4, [0,5,0])
		#data.set_init_velo(5, [0,-5,0])

		data.set_mass(0, 80)
		data.set_mass(1, 6)
		data.set_mass(2, 3)
		data.set_mass(3, 9)
		#data.set_mass(4, 5)
		#data.set_mass(5, 5)
		 
		Nbsim::Simulator.do(data)


		@visualizer = Nbsim::Visualizer_qt.new(self,data)
		@visualizer.connect(SIGNAL('moved(int)'), self, :moved)

		@slider	= Qt::Slider.new(Qt::Horizontal,self)
		@slider.minimum = 0
		@slider.maximum = data.timesteps-1
		@slider.connect(:sliderPressed, self, :slider_pressed)
		@slider.connect(SIGNAL('sliderMoved(int)'), self, :slider_moved)

		#@l_speed = Qt::Label.new("speed ")
		#@l_speed.height = 100

		sub_layout = Qt::HBoxLayout.new
		sub_layout.add_widget(@slider)
		#sub_layout.add_widget(@l_speed)

		main_layout = Qt::VBoxLayout.new
		main_layout.add_widget(@visualizer)
		main_layout.add_layout(sub_layout)

		self.set_layout(main_layout)
	end

	def keyPressEvent(event)
		case event.key
		when Qt::Key_Space:	@visualizer.toggle
		when Qt::Key_J:		@visualizer.change_view
		when Qt::Key_K:		@visualizer.change_view(false)
		when Qt::Key_Plus:		@visualizer.change_speed
		when Qt::Key_Minus:		@visualizer.change_speed(false)
		end
	end


	def moved(time)
		@slider.slider_position = time
	end

	def slider_pressed
		@visualizer.pause
	end

	def slider_moved(value)
		@visualizer.set_time(value)
	end

end

end
