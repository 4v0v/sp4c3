local Animation = {}

function Animation:new(img, max_frame, delay, state, type)
	local obj = {}
		obj.img = img
		obj.max_frame = max_frame
		obj.delay = delay
		obj.state = state or 'stop'
		obj.type = type or 'loop'
		
		obj.current_frame = 1
		obj.timer = 0
		obj.frames = {}
		obj.loop_count = 0
		for i = 1, max_frame do
			obj.frames[i] = love.graphics.newQuad( (i - 1) * img:getWidth()/max_frame, 0, img:getWidth()/max_frame, img:getHeight(), img:getDimensions())
		end

	return setmetatable(obj, {__index = Animation})
end

function Animation:update(dt)
	if self.state == 'pause' or self.state == 'stop' then return end

	self.timer = self.timer + dt

	if self.timer > self.delay then
		local tmp_frame = self.current_frame + 1
		if tmp_frame > self.max_frame then
			if self.type == 'once' then self:stop() goto continue end
			self.loop_count = self.loop_count + 1
			tmp_frame = 1
		end
		self.current_frame = tmp_frame
		self.timer = self.timer - self.delay
		::continue::
	end
end

function Animation:draw(x, y, sx, sy)
	if self.state == 'stop'then return end
	love.graphics.draw(self.img, self.frames[self.current_frame], x, x, _, sx, sy)
end

function Animation:clone() return self:new(self.img, self.max_frame, self.delay, self.state, self.type) end

function Animation:loop() self.type = 'loop' return self end
function Animation:once() self.type = 'once' return self end
function Animation:play() self.state = 'play' return self end
function Animation:pause() self.state = 'pause' return self end
function Animation:stop()
	self.state = 'stop'
	self.current_frame = 1
	self.timer = 0
	self.loop_count = 0
	return self
end

return setmetatable({}, {__call = Animation.new})