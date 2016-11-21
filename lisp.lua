
function true_p(e)
	return e == true
end
function false_p(e)
	return e == false
end
function pair_p(l)
	return type(l) == 'table' and getmetatable(l) == Cons
end
function list_p(l)
	return null_p(l) or pair_p(l)
end
function null_p(l)
	return l == nil
end
function symbol_p(l)
	return type(l) == 'table' and getmetatable(l) == Symbol
end
function number_p(l)
	return type(l) == 'number'
end
function string_p(l)
	return type(l) == 'string'
end

-- Symbol
Symbol = {}
Symbol.__index = Symbol
function Symbol.new(s)
	return setmetatable({s}, Symbol)
end
function Symbol:__tostring()
	return self[1]
end
function Symbol:__eq(o)
	return self[1] == o[1]
end

-- Cons
Cons = {}
Cons.__index = Cons
function Cons.new(car, cdr)
	return setmetatable({car, cdr}, Cons)
end
function Cons:car()
	return self[1]
end
function Cons:cdr()
	return self[2]
end
function Cons:set_car(a)
	self[1] = a
end
function Cons:set_cdr(d)
	self[2] = d
end

-- functions
function car(l)
	assert(pair_p(l), 'requires pair')
	return l:car()
end
function cdr(l)
	assert(pair_p(l), 'requires pair')
	return l:cdr()
end
function cadr(l)
	return car(cdr(l))
end
function caddr(l)
	return car(cdr(cdr(l)))
end
function cadddr(l)
	return car(cdr(cdr(cdr(l))))
end

function set_car(l, a)
	assert(pair_p(l), 'requires pair')
	l:set_car(a)
end
function set_cdr(l, d)
	assert(pair_p(l), 'requires pair')
	l:set_cdr(d)
end

function list(...)
	local l = {...}
	if #l == 0 then
		return nil
	else
		return Cons.new(l[1], list(unpack(l, 2)))
	end
end

function lunpack(args)
	if not null_p(args) then
		return car(args), lunpack(cdr(args))
	end
end

function map(proc, l)
	if null_p(l) then
		return nil
	else
		return Cons.new(proc(car(l)), map(proc, cdr(l)))
	end
end

function length(e)
	assert(list_p(e), 'requires list')
	if null_p(e) then
		return 0
	else
		return 1 + length(cdr(e))
	end
end

function append(l1, l2)
	if null_p(l1) then
		return l2
	else
		return Cons.new(car(l1), append(cdr(l1), l2))
	end
end

function add(...)
	local s = 0
	for i, v in ipairs({...}) do
		s = s + v
	end
	return s
end

function sub(...)
	local l = {...}
	assert(#l > 0, 'sub() requires at least 1 element')
	if #l == 1 then
		return -l[1]
	else
		local s = table.remove(l, 1)
		for i, v in ipairs(l) do
			s = s - v
		end
		return s
	end
end

function mul(...)
	local s = 1
	for i, v in ipairs({...}) do
		s = s * v
	end
	return s
end

function div(...)
	local l = {...}
	assert(#l > 0, 'div() requires at least 1 element')
	if #l == 1 then
		return 1 / l[1]
	else
		local s = table.remove(l, 1)
		for i, v in ipairs(l) do
			s = s / v
		end
		return s
	end
end

function eql(...)
	local l = {...}
	assert(#l > 0, 'eql() requires at least 2 elements')
	local s = table.remove(l, 1)
	for i, v in ipairs(l) do
		if s ~= v then
			return false
		end
	end
	return true
end

function gt(...)
	local l = {...}
	assert(#l > 0, 'gt() requires at least 2 elements')
	local s = table.remove(l, 1)
	for i, v in ipairs(l) do
		if s <= v then
			return false
		end
		s = v
	end
	return true
end

function lt(...)
	local l = {...}
	assert(#l > 0, 'lt() requires at least 2 elements')
	local s = table.remove(l, 1)
	for i, v in ipairs(l) do
		if s >= v then
			return false
		end
		s = v
	end
	return true
end

function pretty(e)
	if symbol_p(e) then
		return tostring(e)
	elseif list_p(e) then
		return '(' .. table.concat({lunpack(map(pretty, e))}, ' ') .. ')'
	else
		return tostring(e)
	end
end

Reader = {}
Reader.__index = Reader
function Reader.new(file)
	return setmetatable({io = io.input(file), buf=nil}, Reader)
end
function Reader:read()
	if self.buf == nil or string.len(self.buf) == 0 then
		self.buf = self.io:read('*l')
		if self.buf == nil then
			return nil
		end
	end
	local c = string.sub(self.buf, 1, 1)
	self.buf = string.sub(self.buf, 2)
	return c
end
function Reader:peek()
	if self.buf == nil or string.len(self.buf) == 0 then
		self.buf = self.io:read('*l')
		if self.buf == nil then
			return nil
		else
			self.buf = self.buf .. '\n'
		end
	end
	return string.sub(self.buf, 1, 1)
end

function is_space(s)
	return s == ' ' or s == '\n' or s == '\t'
end

function is_delimiter(s)
	return is_space(s) or s == '(' or s == ')' or s == "'"
end

function skip_spaces(r)
	while is_space(r:peek()) do
		r:read()
	end
end

global_reader = Reader.new()

function read()
	local r = global_reader
	skip_spaces(r)
	local c = r:peek()
	if c == nil then
		return nil
	end
	assert(c ~= ')')
	if c == '(' then
		r:read()
		return read_list(r)
	elseif c == "'" then
		r:read()
		return list(Symbol.new('quote'), read(r))
	else
		return read_atom(r)
	end
end

function read_list(r)
	local items = {}
	while true do
		skip_spaces(r)
		local c = r:peek()
		assert(c ~= nil)
		if c == ')' then
			break
		end
		table.insert(items, read(r))
	end
	return list(unpack(items))
end

function read_atom(r)
	local buf = ''
	while true do
		local c = r:peek()
		if is_delimiter(c) or c == nil then
			break
		end
		buf = buf .. c
		r:read()
	end
	assert(string.len(buf) > 0)
	local num = tonumber(buf)
	if num ~= nil then
		return num
	else
		return Symbol.new(buf)
	end
end

