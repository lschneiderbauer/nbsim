module Nbsim

# This class visualizes the data gathered by +Simulator+
# It depends on the Qt4 Library (and its Ruby bindings)
#
class Visualizer_qt < Qt::Widget

	RADIUS = 15
	DT_REDRAW = 10
	TRAIL = 40


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
		@dt = 1

		# default view is center of mass - centric
		@view = -1

		@timer = Qt::Timer.new(self)
		@timer.connect(:timeout, self, :move)
		@timer.interval = DT_REDRAW


	end


	def pause
		@timer.stop
	end

	def resume
		@timer.start unless @timer.active?
	end

	def toggle
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

	def change_view(direction=true)

		@view += (direction ? +1 : -1)

		if @view > @data.n-1
			@view = -1
		elsif @view < -1
			@view = @data.n-1
		end
	end

	def change_speed(direction=true)
		@dt += (direction ? +1 : -1)
		self.resume
	end


	def paintEvent(event)
		painter = Qt::Painter.new(self)

		painter.render_hint = Qt::Painter::Antialiasing

		# draw particle
		draw_particles(painter, @t)

		painter.end
	end


private

	def draw_particles(painter,t)

		painter.pen = Qt::Pen.new(Qt::Color.new(0,0,0,0))

		# decide "view"
		#
		case @view
			when -1 : dx,dy,dz = *@data.get_center_of_mass(t)
			else dx,dy,dz = *@data.get_coords(@view,t)
		end


		dx -= self.size.width/2
		dy -= self.size.height/2



		# draw the most backward particle at first and so on..
		# todo..

		(0..@data.n-1).each do |i|

			x,y,z = *@data.get_coords(i,t)
			
			# adjust to center
			x -= dx
			y -= dy
			z -= dz

			# choose radius dependend on mass
			radius = (@data.mass(i).to_f/20 * RADIUS).round

			# .. and dependend on z
			radius = radius + z/20
			radius = 0 if radius < 0

			
			# draw particle
			#
			gradient = Qt::RadialGradient.new(x,y,radius,x+radius/10,y+radius/10)
			gradient.set_color_at(1.0, Qt::Color.new(0,0,0,255))
			gradient.set_color_at(0.0, Qt::Color.new(color_z(z),color_z(z),color_z(z),255))
			painter.brush = Qt::Brush.new(gradient)

			rec = Qt::Rect.new(x-radius,y-radius,radius*2,radius*2)
			painter.draw_ellipse(rec)



			# draw trail
			# todo velocity should relative to view-point, not absolute
			#
			vx,vy,vz = *@data.get_velo(i,t)

			norm = (vx**2 + vy**2)**(0.5)
			vx = vx/norm * radius
			vy = vy/norm * radius

			path = Qt::PainterPath.new
			if vz >= 0
				path.move_to(x-vx,y-vy)
			else
				path.move_to(x,y)
			end

			last_t = 0
			(1..TRAIL).each do |dt|
				if (t-dt) >= 0
					nx, ny = *@data.get_coords(i,t-dt)	
					nx -= dx
					ny -= dy
	
					if ((vz >= 0 && ((x-nx)**2 + (y-ny)**2) > radius**2) || vz < 0)
						path.line_to(nx,ny)
					end
				end
			end

			pen = Qt::Pen.new(Qt::Color.new(0,0,0,100))
			painter.pen = pen
			painter.brush = Qt::Brush.new(Qt::Color.new(0,0,0,0))
			painter.draw_path(path)


		end

		# draw grid (origin in center of mass)
		#
		pen = Qt::Pen.new(Qt::Color.new(0,0,0,150))
		pen.style = Qt::DotLine
		painter.pen = pen
		pen.width = 0.5
		
		x,y = *@data.get_center_of_mass(t)
		x -= dx
		y -= dy

		line_x = Qt::LineF.new(0,y,self.size.width,y)
		line_y = Qt::LineF.new(x,0,x,self.size.height)
		painter.draw_line(line_x)
		painter.draw_line(line_y)

	end

	def color_z(z)
		c = (1 + z/100)/2 * 255

		c = 0 if c < 0
		c = 255 if c > 255

		return c
	end


	def move
		if @t + @dt <= @data.timesteps-1 && @t + @dt >= 0
			@t += @dt
		else
			@t = 0
			@dt = 1	# reset speed
			self.pause
		end
		
		self.update
		emit moved(@t)
	end

end


end
