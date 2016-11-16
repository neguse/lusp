
-- translate from SICP ch5-eceval.scm.

-- Use trampoline to emulate goto statement.
-- Lua 5.2 also has goto statement, but it couldn't save and restore address to/from variables.
function eceval()
	jump = read_eval_print_loop
	while jump do
		jump = jump()
	end
end

function read_eval_print_loop()
	initialize_stack()
	prompt_for_input(";;; EC-Eval input:")
	exp = read()
	env = get_global_environment()
	continue = print_result
	return eval_dispatch
end

function print_result()
  print_stack_statistics()
  announce_output(";;; EC-Eval value:")
  user_print(val)
  return read_eval_print_loop
end

function unknown_expression_type()
  val = unknown_expression_type_error
  return signal_error
end

function unknown_procedure_type()
	continue = restore()
	val = unknown_procedure_type_error
	return signal_error
end

function signal_error()
	user_print(val)
	return read_eval_print_loop
end

function eval_dispatch()
	if self_evaluating_p(exp) then
		return ev_self_eval
	end
	if variable_p(exp) then
		return ev_variable
	end
	if quoted_p(exp) then
		return ev_quoted
	end
	if assignment_p(exp) then
		return ev_assignment
	end
	if definition_p(exp) then
		return ev_definition
	end
	if if_p(exp) then
		return ev_if
	end
	if lambda_p(exp) then
		return ev_lambda
	end
	if begin_p(exp) then
		return ev_begin
	end
	if application_p(exp) then
		ev_application
	end
	return unknown_expression_type

function ev_self_eval()
	val = exp
	return continue
end

function ev_variable()
	val = lookup_variable_value(exp, env)
	return continue
end

function ev_quoted()
	val = (text_of_quotation(exp)
	return continue
end

function ev_lambda()
	unev = lambda_parameters(exp)
	exp = lambda_body(exp)
	val = make_procedure(unev, exp, env)
	return continue
end

function ev_application()
	save(continue)
	save(env)
	unev = operands(exp)
	save(unev)
	exp = operator(exp)
	continue = (ev_appl_did_operator
	return eval_dispatch
end

function ev_appl_did_operator()
	unev = restore()
	env = restore()
	argl = empty_arglist()
	proc = val
	if no_operands_p(unev) then
		return apply_dispatch
	end
	save(proc)
	return ev_appl_operand_loop

function ev_appl_operand_loop()
	save(argl)
	exp = first_operand(unev)
	if last_operand_p(unev) then
		return ev_appl_last_arg
	end
	save(env)
	save(unev)
	continue = ev_appl_accumulate_arg
	return eval_dispatch
end

function ev_appl_accumulate_arg()
	unev = restore()
	env = restore()
	argl = restore()
	argl = adjoin_arg(val, argl)
	unev = rest_operands(unev)
	return ev_appl_operand_loop
end

function ev_appl_last_arg()
	continue = ev_appl_accum_last_arg
	return eval_dispatch
end

function ev_appl_accum_last_arg()
	argl = restore()
	argl = adjoin_arg(val, argl)
	proc = restore()
	return apply_dispatch

function apply_dispatch()
	if primitive_procedure_p(proc) then
		return primitive_apply
	end
	if compound_procedure_p(proc) then
		return compound_apply
	end
	return unknown_procedure_type
end

function primitive_apply()
	val = apply_primitive_procedure(proc, argl)
	continue = restore()
	return continue
end

function compound_apply()
	unev = procedure_parameters(proc)
	env = procedure_environment(proc)
	env = extend_environment(unev, argl, env)
	unev = procedure_body(proc)
	return ev_sequence
end

function ev_begin()
	unev = begin_actions(exp)
	save(continue)
	return ev_sequence
end

function ev_sequence()
	exp = first_exp(unev)
	if last_exp_p(unev) then
		return ev_sequence_last_exp)
	end
	save(unev)
	save(env)
	continue = ev_sequence_continue
	return eval_dispatch
end

function ev_sequence_continue()
	env = restore()
	unev = restore()
	unev = rest_exps(unev)
	return ev_sequence
end

function ev_sequence_last_exp()
	continue = restore()
	return eval_dispatch
end

function ev_if()
	save(exp)
	save(env)
	save(continue)
	continue = ev_if_decide
	exp = if_predicate(exp)
	return eval_dispatch
end

function ev_if_decide()
	continue = restore()
	env = restore()
	exp = restore()
	if true_p(val) then
		return ev_if_consequent
	return ev_if_alternative
end

function ev_if_alternative()
	exp = if_alternative(exp)
	return eval_dispatch
end

function ev_if_consequent()
	exp = if_consequent(exp)
	return eval_dispatch
end

function ev_assignment()
	unev = assignment_variable(exp)
	save(unev)
	exp = assignment_value(exp)
	save(env)
	save(continue)
	continue = ev_assignment_1
	return eval_dispatch
end

function ev_assignment_1()
	continue = restore()
	env = restore()
	unev = restore()
	set_variable_value(unev, val, env)
	val = ok
	return continue
end

function ev_definition()
	unev = definition_variable(exp)
	save(unev)
	exp = definition_value(exp)
	save(env)
	save(continue)
	continue = ev_definition_1
	return eval_dispatch
end

function ev_definition_1()
	continue = restore()
	env = restore()
	unev = restore()
	definition_variable(unev, val, env)
	val = ok
	return continue
end

