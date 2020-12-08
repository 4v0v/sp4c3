Segment = Class:extend('Segment')

function Segment:new(x, y, length, angle)
	self.length   = length
	self.angle    = angle % (math.pi*2)
	self.a        = Vec2(x, y)
	self.b        = self.a + Vec2.from_cartesian(self.length, self.angle)
end

function Segment:set_a(x, y)
	self.a = Vec2(x, y)
	self.b = self.a + Vec2.from_cartesian(self.length, self.angle)
end

function Segment:set_b(x, y)
	self.b = Vec2(x, y)
	self.a = self.b + Vec2.from_cartesian(self.length, self.angle)
end

function Segment:a_follow(target_x, target_y)
	local _target = Vec2(target_x, target_y)
	local _dir    = _target - self.b

	self.angle = _dir:angle()
	self.a     = _target
	self.b     = self.a - Vec2.from_cartesian(self.length, self.angle)
end

function Segment:b_follow(target_x, target_y)
	local _target = Vec2(target_x, target_y)
	local _dir    = _target - self.a

	self.angle = _dir:angle()
	self.b     = _target
	self.a     = self.b - Vec2.from_cartesian(self.length, self.angle)
end
