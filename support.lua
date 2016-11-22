
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
		return Cons.new(make_frame(vars, vals), base_env)
	elseif length(vars) < length(vals) then
		error("Too many arguments supplied " .. tostring(vars) .. tostring(vals))
	else
		error("Too few arguments supplied " .. tostring(vars) .. tostring(vals))
	end
end
function lookup_variable_value(var, env)
	local env_loop
	env_loop = function(env)
		local scan
		scan = function(vars, vals)
			if null_p(vars) then
				return env_loop(enclosing_environment, env)
			elseif var == car(vars) then
				return car(vals)
			else
				return scan(cdr(vars), cdr(vals))
			end
		end
		if env == the_empty_environment then
			error("Unbound variable " .. tostring(var))
		else
			frame = first_frame(env)
			return scan(frame_variables(frame), frame_values(frame))
		end
	end
	return env_loop(env)
end

function set_variable_value(var, val, env)
	local env_loop
	env_loop = function(env)
		local scan
		scan = function(vars, vals)
			if null_p(vars) then
				env_loop(enclosing_environment, env)
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
	local scan
	scan = function(vars, vals)
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

function setup_environment()
	initial_env = extend_environment(
		primitive_procedure_names(),
		primitive_procedure_objects(),
		the_empty_environment)
	define_variable(Symbol.new('true'), true, initial_env)
	define_variable(Symbol.new('false'), false, initial_env)
	return initial_env
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
	list(Symbol.new('<'), lt))

function primitive_procedure_names()
	return map(car, primitive_procedures)
end

function primitive_procedure_objects()
	f = function(proc)
		return list(Symbol.new('primitive'), cadr(proc))
	end
	return map(f, primitive_procedures)
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
		print(pretty(list(
				Symbol.new('compound-procedure'),
				procedure_parameters(object),
				procedure_body(object),
				Symbol.new('<procedure-env>'))))
	else
		print(pretty(object))
	end
end

function empty_arglist()
	return nil
end
function adjoin_arg(arg, arglist)
	return append(arglist, list(arg))
end

function last_operand_p(ops)
	return null_p(cdr(ops))
end

function no_more_exps_p(seq)
	null_p(seq)
end

the_global_environment = setup_environment()

function get_global_environment()
	return the_global_environment
end


-- syntax

function self_evaluating_p(exp)
	return number_p(exp) or string_p(exp)
end

function quoted_p(exp)
	return tagged_list_p(exp, Symbol.new('quote'))
end
function text_of_quotation(exp)
	return cadr(exp)
end

function variable_p(exp)
	return symbol_p(exp)
end

function assignment_p(exp)
	return tagged_list_p(exp, Symbol.new('set!'))
end
function assignment_variable(exp)
	return cadr(exp)
end
function assignment_value(exp)
	return caddr(exp)
end

function definition_p(exp)
	return tagged_list_p(exp, Symbol.new('define'))
end
function definition_variable(exp)
	if symbol_p(cadr(exp)) then
		return cadr(exp)
	else
		return caddr(exp)
	end
end
function definition_value(exp)
	if symbol_p(cadr(exp)) then
		return caddr(exp)
	else
		return make_lambda(caddr(exp), cddr(exp))
	end
end

function lambda_p(exp)
	return tagged_list_p(exp, Symbol.new('lambda'))
end
function lambda_parameters(exp)
	return cadr(exp)
end
function lambda_body(exp)
	return cddr(exp)
end

function make_lambda(parameters, body)
	return Cons.new(Symbol.new('lambda'), Cons.new(parameters, body))
end

function if_p(exp)
	return tagged_list_p(exp, Symbol.new('if'))
end
function if_predicate(exp)
	return cadr(exp)
end
function if_consequent(exp)
	return caddr(exp)
end
function if_alternative(exp)
	if not null_p(cdddr(exp)) then
		return cadddr(exp)
	else
		return Symbol.new('false')
	end
end

function begin_p(exp)
	return tagged_list_p(exp, Symbol.new('begin'))
end
function begin_actions(exp)
	return cdr(exp)
end

function last_exp_p(seq)
	return null_p(cdr(seq))
end
function first_exp(seq)
	return car(seq)
end
function rest_seq(seq)
	return cdr(seq)
end

function application_p(exp)
	return pair_p(exp)
end
function operator(exp)
	return car(exp)
end
function operands(exp)
	return cdr(exp)
end

function no_operands_p(ops)
	return null_p(ops)
end
function first_operand(ops)
	return car(ops)
end
function rest_operands(ops)
	return cdr(ops)
end


