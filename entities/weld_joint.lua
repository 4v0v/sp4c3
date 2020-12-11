Weld_joint = Entity:extend("Weld_joint")

function Weld_joint:new(x, y, physics)
	Weld_joint.super.new(self, {x = x, y = y})

	self.physics = physics

	self.collider1 = self.physics:add_circle(x,y, 30)
	self.collider1:set_data(self)

	self.collider2 = self.physics:add_circle(x, y+100, 30):set_mode("fill"):set_color(0, 0, 0)
	self.collider2:set_data(self)

	self.joint1 = self.physics:add_joint("weld", 
		self.collider1, self.collider2, 
		self.collider1:getX(), self.collider1:getY()
	)
end

function Weld_joint:kill()
	Weld_joint.super.kill(self)

	self.joint1:destroy()
	self.collider1:destroy()
	self.collider2:destroy()
end

function Weld_joint:update(dt)
	Weld_joint.super.update(self, dt)

	self.pos = Vec2(self.collider1:getPosition())
end

function Weld_joint:draw()
	self.collider1:draw()
	self.collider2:draw()
	self.joint1:draw()


	lg.setColor(0, .5, .5)
	lg.line(
		self.collider1:getX(), 
		self.collider1:getY(),
		self.collider2:getX(), 
		self.collider2:getY()
	)
end
