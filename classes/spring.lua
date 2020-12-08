Spring = Class:extend('Spring')

function Spring:new(value, k, d)
    self.target_val = value
    self.val        = value

    self.k = k or 100
    self.d = d or 10
    self.v = 0
end

function Spring:update(dt)
    local temp_value = self.val - self.target_val
    local a = -self.k* temp_value - self.d*self.v
    self.v = self.v + a*dt
    self.val = self.val + self.v*dt
end

function Spring:pull(force, k, d)
    self.val = self.val + force
    if k then self.k = k end
    if d then self.d = d end
end

function Spring:value() return self.val end
function Spring:set_value(x) self.target_val, self.val = x, x end