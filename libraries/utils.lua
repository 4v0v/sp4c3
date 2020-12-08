function uid() 
	return ("xxxxxxxxxxxxxxxx"):gsub("[x]", function() 
		local r = math.random(16) return ("0123456789ABCDEF"):sub(r, r) 
	end) 
end

function get(object, path, default)
	local value = object

	if type(object) == 'table' then
		if type(path) == 'table' then
			local c = 1
			while type(path[c]) ~= 'nil' do
				if type(value) ~= 'table' then return default end
				value = value[path[c]]
				c = c + 1
			end
		elseif type(path) == 'string' then
			local keys = {}
			for match in (path..'.'):gmatch('(.-)%.') do table.insert(keys, match) end
			return get(object, keys, default)
		end
	end

	return value or default
end

function lerp(a, b, x) 
	return a + (b - a) * x 
end

function cerp(a, b, x) 
	local f=(1-math.cos(x*math.pi))*.5 
	return a*(1-f)+b*f 
end

function clamp(low, n, high) 
	return math.min(math.max(low, n), high) 
end

function require_all(path, opts)
	local items = love.filesystem.getDirectoryItems(path)
	for _, item in pairs(items) do
		if love.filesystem.getInfo(path .. '/' .. item, 'file') then 
			require(path .. '/' .. item:gsub('.lua', '')) 
		end
	end
	if opts and opts.recursive then 
		for _, item in pairs(items) do
			if love.filesystem.getInfo(path .. '/' .. item, 'directory') then 
				require_all(path .. '/' .. item, {recursive = true}) 
			end
		end
	end
end

function table.size(t)
	local s = 0 
	for _ in pairs(t) do s = s + 1 end 
	return s 
end

function table.keys(t) 
	local _keys = {} 
	for k, _ in pairs(t) do _keys[#_keys + 1] = k end 
	return _keys 
end

function table.values(t)
	local _values = {} 
	for _, v in pairs(t) do _values[#_values + 1] = v end 
	return _values 
end

function table.print(t)
	if type(t) ~= 'table' then print(t) return end

	local tables, functions, others = {}, {}, {}
	for k, v in pairs(t) do 
		if type(v) == 'table' then
			local s = 0 for _ in pairs(v) do s = s + 1 end 
			table.insert(tables, {key = k, size = s}) 
		elseif type(v) == 'function' then 
			table.insert(functions, {key = k})
		else
			table.insert(others, {key = k, value = v})
		end
	end

	table.sort(tables,    function(a, b) return a.key < b.key end)
	table.sort(functions, function(a, b) return a.key < b.key end)
	table.sort(others,    function(a, b) return a.key < b.key end)

	for k,v in pairs(tables)    do if v.size == 0 then print(v.key .. ' : {}') else print(v.key .. ' : {...}') end end
	for k,v in pairs(functions) do print(v.key .. '()') end
	for k,v in pairs(others)    do print(v.key .. ' : ' .. tostring(v.value)) end
end

function table.random_value(t) 
	local _values = {} 
	for _, v in pairs(t) do _values[#_values + 1] = v end
	return _values[math.random(#_values)]
end

function table.random_key(t) 
	local keys = {} 
	for k, _ in pairs(t) do keys[#keys + 1] = k end
	return keys[math.random(#keys)]
end

function circ_circ_collision(c1, c2)
	return (c2.x - c1.x)^2 + (c2.y - c1.y)^2 < ((c1.r + c2.r)^2)
end

function rect_rect_collision(r1, r2)
	return r1.x < r2.x + r2.w and r1.x + r1.w > r2.x and r1.y < r2.y + r2.h and r1.h + r1.y > r2.y
end

function circ_rect_collision(c, r)
	local _x, _y
  if c.x < r.x then _x = r.x elseif c.x > r.x + r.w then _x = r.x + r.w else _x = c.x end
  if c.y < r.y then _y = r.y elseif c.y > r.y + r.h then _y = r.y + r.h else _y = c.y end
	return math.sqrt( (c.x - _x)^2 + (c.y - _y)^2 ) <= c.r
end

function rect_circ_collision(r, c) 
	local _x, _y
  if c.x < r.x then _x = r.x elseif c.x > r.x + r.w then _x = r.x + r.w else _x = c.x end
  if c.y < r.y then _y = r.y elseif c.y > r.y + r.h then _y = r.y + r.h else _y = c.y end
	return math.sqrt( (c.x - _x)^2 + (c.y - _y)^2 ) <= c.r
end

function rect_point_collision(r, p)
	return p.x >= r.x and p.x <= r.x + r.w and p.y >= r.y and p.y <= r.y + r.h
end

function point_rect_collision(p, r)
	return p.x >= r.x and p.x <= r.x + r.w and p.y >= r.y and p.y <= r.y + r.h
end

function point_circ_collision(p, c)
  return math.sqrt( (p.x - c.x)^2 + (p.y - c.y)^2 ) <= c.r 
end

function circ_point_collision(c, p)
	return math.sqrt( (p.x - c.x)^2 + (p.y - c.y)^2 ) <= c.r 
end

function rect_rect_inside(r1, r2) 
	return r1.x >= r2.x and r1.y >= r2.y and r1.x + r1.w <= r2.x + r2.w and r1.y + r1.h <= r2.y + r2.h 
end

function rect_center(r)
	return r.x + r.w / 2, r.y + r.h / 2
end

function angle_between_3_points(p1, p2, p3)
	local p1c  = math.sqrt((p2.x-p1.x)^2 + (p2.y-p1.y)^2) 
	local p3c  = math.sqrt((p2.x-p3.x)^2 + (p2.y-p3.y)^2)
	local p1p3 = math.sqrt((p3.x-p1.x)^2 + (p3.y-p1.y)^2)
	
	return math.acos((p3c*p3c+p1c*p1c-p1p3*p1p3)/(2*p3c*p1c))
end
