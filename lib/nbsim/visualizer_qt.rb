module Nbsim

# This class visualizes the data gathered by +Simulator+
# It depends on the Qt4 Library (and its Ruby bindings)
#
class Visualizer_qt < Qt::Widget

	RADIUS = 7
	DT_REDRAW = 5


	signals 'moved(int)'

	# Initializes the Qt Widget
	#
        # [data]        Expects a +Nbsim::Database+ object filled with data.
	# 		(normally from +Nbsim::Simulator+
	#
	def initialize(parent,data)
		super(parent)

		@data = data
		@t = 0




		@timer = Qt::Timer.new(self)
		@timer.connect(:timeout, self, :move)

		@timer.start DT_REDRAW

	end


	def pause
		@timer.stop
	end

	def resume
		@timer.start
	end

	def pause_or_resume
		if @timer.is_active
			@timer.stop
		else
			@timer.start
		end
	end

	def set_time(time)
		@t = time
		self.update
	end

	def reset
		@t = 0
	end


	def paintEvent(event)
		painter = Qt::Painter.new(self)

		painter.pen = Qt::Pen.new(Qt::SolidLine)
		painter.brush = Qt::Brush.new(Qt::black)


		# center it to center of mass
		#
		dx,dy = *@data.get_center_of_mass(@t)
		dx -= self.size.width/2
		dy -= self.size.height/2


		(0..@data.n-1).each do |i|

			x,y = *@data.get_coords(i,@t)
			
			# adjust to center
			x -= dx
			y -= dy

			# choose radius dependend on mass
			radius = (@data.mass(i).to_f/20 * RADIUS).round

			# draw particle
			rec = Qt::Rect.new(x-radius,y-radius,radius*2,radius*2)
			painter.draw_ellipse(rec)
		end

		painter.end
	end


private

	def move
		@t += 1 if @t < @data.timesteps-1
		self.update

		emit moved(@t)
	end

end


end
