Distance_joint = Entity:extend("Distance_joint")

function Distance_joint:new(x, y, physics)
	Distance_joint.super.new(self, {x = x, y = y})

	self.physics = physics

	self.collider1 = self.physics:add_circle(x,y, 30)
	self.collider1:set_data(self)

	self.collider2 = self.physics:add_circle(x, y+100, 30):set_mode("fill"):set_color(0, 0, 0)
	self.collider2:set_data(self)

	self.joint1 = self.physics:add_joint("distance", 
		self.collider1, self.collider2, 
		self.collider1:getX(), self.collider1:getY(),
		self.collider2:getX(), self.collider2:getY()
	)
end

function Distance_joint:kill()
	Distance_joint.super.kill(self)

	self.joint1:destroy()
	self.collider1:destroy()
	self.collider2:destroy()
end

function Distance_joint:update(dt)
	Distance_joint.super.update(self, dt)

	self.pos = Vec2(self.collider1:getPosition())
end

function Distance_joint:draw()
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
