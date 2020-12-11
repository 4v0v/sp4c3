Square_guy = Entity:extend("Square_guy")

Square_guy.img = lg.newImage("assets/Square_guy.png")

function Square_guy:new(x, y, physics)
	Square_guy.super.new(self, {x = x, y = y})

	self.w = 100
	self.h = 50

	self.dx = 0
	self.dy = 0

	self.physics = physics
	self.img = Square_guy.img
	self.img_w, self.img_h = self.img:getDimensions()

	self.w_scale = self.w/self.img_w
	self.h_scale = self.h/self.img_h

	self.collider = self.physics:add_rectangle(x,y, self.w, self.h)
	self.collider:set_class("Enemy")
	self.collider:set_data(self)

	self.pos = Vec2(self.collider:getPosition())
end

function Square_guy:kill()
	Square_guy.super.kill(self)
	self.collider:destroy()
end

function Square_guy:update(dt)
	Square_guy.super.update(self, dt)
end

function Square_guy:draw()

	lg.push()
	lg.translate(self.collider:getX(), self.collider:getY())
	lg.rotate(self.collider:getAngle())
	lg.draw(self.img, -self.w/2, -self.h/2, _, self.w_scale,self.h_scale)
	lg.pop()
end
