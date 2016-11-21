
require("lisp")

function tagged_list_p(l, tag)
	if pair_p(l) then
		return l:car() == tag
	end
	return false
end

-- compound procedure
function make_procedure(parameters, body, env)
	return list(Symbol.new('procedure'), parameters, body, env)
end
function compound_procedure_p(p)
	return tagged_list_p(p, Symbol.new('procedure'))
end
function procedure_parameters(p)
	return cadr(p)
end
function procedure_body(p)
	return caddr(p)
end
function procedure_environment(p)
	return cadddr(p)
end


function enclosing_environment(env)
	return cdr(env)
end
function first_frame(env)
	return car(env)
end
the_empty_environment = nil
function make_frame(vars, vals)
	return Cons.new(vars, vals)
end
function frame_variables(frame)
	return car(frame)
end
function frame_values(frame)
	return cdr(frame)
end
function add_binding_to_frame(var, val, frame)
	set_car(frame, Cons.new(var, car(frame)))
	set_cdr(frame, Cons.new(val, cdr(frame)))
end
function extend_environment(vars, vals, base_env)
	if length(vars) == length(vals) then
		return make_frame(vars, vals)
	elseif length(vars) < length(vals) then
		error("Too many arguments supplied " .. tostring(vars) .. tostring(vals))
	else
		error("Too few arguments supplied " .. tostring(vars) .. tostring(vals))
	end
end
function lookup_variable_value(var, env)
	local env_loop = function(env)
		local scan = function(vars, vals)
			if null_p(vars) then
				return env_loop(enclosing_environment, env)
			elseif var == car(vars) then
				return car(vals)
			else
				scan(cdr(vars), cdr(vals))
			end
		end
		if env == the_empty_environment then
			error("Unbound variable " .. tostring(var))
		else
			frame = first_frame(env)
			scan(frame_variables(frame), frame_values(frame))
		end
	end
	env_loop(env)
end

function set_variable_value(var, val, env)
	local env_loop = function(env)
		local scan = function(vars, vals)
			if null_p(vars) then
				return env_loop(enclosing_environment, env)
			elseif var == car(vars) then
				set_car(vals, val)
			else
				scan(cdr(vars), cdr(vals))
			end
		end
		if env == the_empty_environment then
			error("Unbound variable -- SET!" .. tostring(var))
		else
			frame = first_frame(env)
			scan(frame_variables(frame), frame_values(frame))
		end
	end
	env_loop(env)
end

function define_variable(var, val, env)
	frame = first_frame(env)
	local scan = function(vars, vals)
		if null_p(vars) then
			add_binding_to_frame(var, val, frame)
		elseif var == car(vars) then
			set_car(vals, val)
		else
			scan(cdr(vars), cdr(vals))
		end
	end
	scan(frame_variables(frame), frame_values(frame))
end


function primitive_procedure_p(p)
	return tagged_list_p(p, Symbol.new('primitive'))
end
function primitive_implementation(proc)
	return cadr(proc)
end
primitive_procedures = list(
	list(Symbol.new('car'), car),
	list(Symbol.new('cdr'), cdr),
	list(Symbol.new('cons'), Cons.new),
	list(Symbol.new('null?'), null_p),
	list(Symbol.new('+'), add),
	list(Symbol.new('-'), sub),
	list(Symbol.new('*'), mul),
	list(Symbol.new('/'), div),
	list(Symbol.new('='), eql),
	list(Symbol.new('>'), gt),
	list(Symbol.new('<'), lt),)

function primitive_procedure_names()
	return map(car, primitive_procedures)
end

function primitive_procedure_objects()
	f = function(proc)
		return list(Symbol.new('primitive'), cadr(proc))
	end
	return map(f, primitive_procedures)
end

function lunpack(args)
	if not null_p(args)
		return car(args), lunpack(cdr(args))
	end
end

function apply_primitive_procedure(proc, args)
	return primitive_implementation(proc)(lunpack(args))
end

function prompt_for_input(str)
	print("\n\n" .. str .. "\n")
end
function announce_output(str)
	print("\n" .. str .. "\n")
end
function user_print(object)
	if compound_procedure_p(object) then
		print(list(
				Symbol.new('compound-procedure'),
				procedure_parameters(object),
				procedure_body(object),
				Symbol.new('<procedure-env>')))
	else
		print(object)
	end
end

