module Nbsim

# This class visualizes the data gathered by +Simulator+
# It depends on the Qt4 Library (and its Ruby bindings)
#
class Visualizer_qt < Qt::Widget

	DT_REDRAW = 5


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




	def paintEvent(event)
		painter = Qt::Painter.new(self)

		painter.pen = Qt::Pen.new(Qt::SolidLine)
		painter.brush = Qt::Brush.new(Qt::black)


		dx,dy = *@data.get_center_of_mass(@t)
		dx -= self.size.width/2
		dy -= self.size.height/2


		(0..@data.n-1).each do |i|

			x,y = *@data.get_coords(i,@t)
			
			x -= dx
			y -= dy

			rec = Qt::Rect.new(x-3,y-3,3*2,3*2)
			painter.draw_ellipse(rec)
		end

		painter.end
	end


private

	def move
		@t += 1
		self.update
	end

end


end
