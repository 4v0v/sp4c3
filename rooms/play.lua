Play = Room:extend('Play')

function Play:new(id)
	Play.super.new(self, id)

	self.physics = Physics()
	self.physics:add_class("Enemy")

	self:add("vaisseau", Vaisseau(0, 0, self.physics))
	self:add(Square_guy(100, 100, self.physics))


	self.physics:add_chain("chain", true, {-300, -300, 300, -300, 300, 300, -300, 300})
end

function Play:update(dt)
	Play.super.update(self, dt)
	self.physics:update(dt)

	local vaisseau = self:get("vaisseau")
	if down("q") then vaisseau:move_left() end
	if down("d") then vaisseau:move_right() end
	if down("z") then vaisseau:move_forward() end


	self:follow(vaisseau.pos.x, vaisseau.pos.y)
end

function Play:draw_inside_cam()
	-- local chain_points = {self.chain:getWorldPoints(self.chain:get_shape("main"):getPoints())}
	-- for i=1, #chain_points, 2 do 
	-- 	if i < #chain_points-2 then lg.line(chain_points[i], chain_points[i+1], chain_points[i+2], chain_points[i+3]) end 
	-- end

	-- local chain = self.physics:get_collider("chain")
	-- chain:draw()

	self.physics:draw()
end
