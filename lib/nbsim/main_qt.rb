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
		data.set_init_cond(0, [100, -90])
		data.set_init_cond(1, [300, -40])
		data.set_init_cond(2, [0, 0])

		data.set_mass(0, 3)
		data.set_mass(1, 7)
		data.set_mass(2, 13)
		 
		Nbsim::Simulator.do(data)




		@visualizer = Nbsim::Visualizer_qt.new(self,data)
		@visualizer.connect(SIGNAL('moved(int)'), self, :moved)

		@slider	= Qt::Slider.new(Qt::Horizontal,self)
		@slider.minimum = 0
		@slider.maximum = data.timesteps-1
		@slider.connect(:sliderPressed, self, :slider_pressed)
		@slider.connect(:sliderReleased, self, :slider_released)
		@slider.connect(SIGNAL('sliderMoved(int)'), self, :slider_moved)

		@c_button = Qt::PushButton.new("pause/resume")
		@c_button.connect(:clicked, self, :c_button_clicked)

		sublayout = Qt::HBoxLayout.new
		sublayout.add_widget(@c_button)
		sublayout.add_widget(@slider)

		layout = Qt::VBoxLayout.new
		layout.add_widget(@visualizer)
		layout.add_layout(sublayout)

		self.set_layout(layout)


	end


	def moved(time)
		@slider.slider_position = time
	end

	def slider_pressed
		@visualizer.pause
	end

	def slider_released
		@visualizer.resume
	end

	def slider_moved(value)
		@visualizer.set_time(value)
	end

	def c_button_clicked
		@visualizer.pause_or_resume
	end

end

end
