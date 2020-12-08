Vaisseau = Entity:extend("Vaisseau")

function Vaisseau:new(x, y, world)
	Vaisseau.super.new(self, {x = x, y = y})
	self.world = world
	self.alpha = 1
    
	local c = self.world:add_polygon(self.x, self.y, {0, 0,  50, -12, 50, 12})
	c:add_shape("right_wing", "polygon", {50, -12,  50, -24, 20, -18})
	c:add_shape("left_wing" , "polygon", {50,  12,  50,  24, 20,  18})
	local mx, my = c:getWorldCenter()
	c:destroy()

	self.collider = self.world:add_circle(mx, my, 5):set_color(1,0.3,0)

	self.collider:get_shape("main"):set_color(1,1,1):set_mode("fill")
	self.collider:add_shape("body"      , "polygon", { 0 - mx,   0 - my,  50 - mx, -12 - my, 50 - mx,  12 - my})
	self.collider:add_shape("left_ps"   , "circle" , 50 - mx, 18 - my, 5):set_color(0,1,0):isSensor(true)
	self.collider:add_shape("right_ps"  , "circle" , 50 - mx, -18 - my, 5):set_color(0,1,0):isSensor(true)
	self.collider:add_shape("right_wing", "polygon", {50 - mx, -12 - my,  50 - mx, -24 - my, 20 - mx, -18 - my}):set_color(1,0,1):set_mode("fill")
	self.collider:add_shape("left_wing" , "polygon", {50 - mx,  12 - my,  50 - mx,  24 - my, 20 - mx,  18 - my}):set_color(1,0,1):set_mode("fill")
	self.collider:setLinearDamping(0.8)
	self.collider:setAngularDamping(4)
	self.collider:set_data(self)
	
	local p_system = lg.newParticleSystem(lg.newImage("assets/pixel_particle.png"))
	p_system:setParticleLifetime(0.3, 0.6)
	p_system:setTangentialAcceleration(-200, 200)
	p_system:setColors(
			1, 1, 1, 1,
			1, 1, 1, 1,
			1, 1, 1, 1,
			1, 1, 1, 1,
			1, 1, 1, 1,
			1, 1, 1, 1,
			1, 1, 1, 0
	)
	self.left_ps  = p_system:clone()
	self.right_ps = p_system:clone()

	self.total_carburant   = 100
	self.current_carburant = 100
	self.er_max  = 50
	self.er_min  = 0
	self.left_er_current  = self.er_min
	self.right_er_current = self.er_min
end

function Vaisseau:update(dt)
	Vaisseau.super.update(self, dt)
	self.left_ps:update(dt)
	self.right_ps:update(dt)

	local _lx, _ly = self.collider:getWorldPoints(self.collider:get_shape("left_ps"):getPoint())
	local _rx, _ry = self.collider:getWorldPoints(self.collider:get_shape("right_ps"):getPoint())
	self.left_ps:setPosition(_lx, _ly)
	self.right_ps:setPosition(_rx, _ry)

	if self.left_er_current  > self.er_min then self.left_er_current  = self.left_er_current  - 1 end
	if self.right_er_current > self.er_min then self.right_er_current = self.right_er_current - 1 end
	if self.left_er_current  < self.er_min then self.left_er_current  = self.er_min end
	if self.right_er_current < self.er_min then self.right_er_current = self.er_min end
	self.left_ps:setEmissionRate(self.left_er_current)
	self.right_ps:setEmissionRate(self.right_er_current)

	local _min_vx, _min_vy = math.cos(self.collider:getAngle() - math.rad(10)) * 600, math.sin(self.collider:getAngle() - math.rad(10)) * 600
	local _max_vx, _max_vy = math.cos(self.collider:getAngle() + math.rad(10)) * 600, math.sin(self.collider:getAngle() + math.rad(10)) * 600
	self.left_ps:setLinearAcceleration(_min_vx, _min_vy, _max_vx, _max_vy)
	self.right_ps:setLinearAcceleration(_min_vx, _min_vy, _max_vx, _max_vy)


	self.pos = Vec2(self.collider:getPosition())
end

function Vaisseau:draw()
	self.collider:set_alpha(self.alpha)
	self.collider:draw()

	-- local main = self.collider:get_shape("main")
	-- local body = self.collider:get_shape("body")
	-- local left_ps = self.collider:get_shape("left_ps")
	-- local right_ps = self.collider:get_shape("right_ps")
	-- local right_wing = self.collider:get_shape("right_wing")
	-- local left_wing = self.collider:get_shape("left_wing")

	-- local _r, _x, _y = main:getRadius(), self.collider:getWorldPoints(main:getPoint())
	-- lg.circle("fill", _x, _y, _r)


	-- local _r, _x, _y =left_ps:getRadius(), self.collider:getWorldPoints(left_ps:getPoint())
	-- lg.circle("fill", _x, _y, _r)

	-- local _r, _x, _y = right_ps:getRadius(), self.collider:getWorldPoints(right_ps:getPoint())
	-- lg.circle("fill", _x, _y, _r)

	-- lg.polygon("line", self.collider:getWorldPoints(body:getPoints()))
	-- lg.polygon("line", self.collider:getWorldPoints(left_wing:getPoints()))
	-- lg.polygon("line", self.collider:getWorldPoints(right_wing:getPoints()))

	lg.draw(self.left_ps, 0, 0)
	lg.draw(self.right_ps, 0, 0)
end

function Vaisseau:move_left()
    self.collider:applyTorque(-5000)
    if self.right_er_current < self.er_max then self.right_er_current = self.right_er_current + 1.5 end
    if self.right_er_current > self.er_max then self.right_er_current = self.er_max end
end

function Vaisseau:move_right()
    if self.left_er_current  < self.er_max then self.left_er_current  = self.left_er_current  + 1.5 end
    if self.left_er_current  > self.er_max then self.left_er_current  = self.er_max end
    self.collider:applyTorque(5000) 
end

function Vaisseau:move_forward() 
    if self.left_er_current  < self.er_max then self.left_er_current  = self.left_er_current  + 1.5 end
    if self.right_er_current < self.er_max then self.right_er_current = self.right_er_current + 1.5 end
    if self.left_er_current  > self.er_max then self.left_er_current  = self.er_max end
    if self.right_er_current > self.er_max then self.right_er_current = self.er_max end

    self.collider:applyForce(-math.cos(self.collider:getAngle())*1000, -math.sin(self.collider:getAngle())*1000) 
    if self.current_carburant < 0 then self.current_carburant = 0 end 
    if self.current_carburant > 0 then self.current_carburant = self.current_carburant - 0.3 end
end
