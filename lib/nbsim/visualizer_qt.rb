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

		#dx = 300 - @data.coord(0,0,@t)
		#dy = 300 - @data.coord(0,1,@t)

		dx = 300
		dy = 300

		(0..@data.n-1).each do |i|

			x,y = *@data.get_coords(i,@t)
			
			x = x + dy
			y = y + dy

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
