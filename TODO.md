
# Implement data types

- nil
- boolean
- number
- string
- symbol
- cons

# Implement operations

## primitive Scheme operations

- car
- cdr
- cons
- null_p
- +
- -
- *
- =
- /
- >
- <
- read

## operations in syntax.scm 

- self_evaluating_p
- quoted_p
- text_of_quotation
- variable_p
- assignment_p
- assignment_variable
- assignment_value
- definition_p
- definition_variable
- definition_value
- lambda_p
- lambda_parameters
- lambda_body
- if_p
- if_predicate
- if_consequent
- if_alternative
- begin_p
- begin_actions
- last_exp_p
- first_exp
- rest_exps
- application_p
- operator
- operands
- no_operands_p
- first_operand
- rest_operands

## operations in eceval-support.scm

- true_p
- make_procedure
- compound_procedure_p
- procedure_parameters
- procedure_body
- procedure_environment
- extend_environment
- lookup_variable_value
- set_variable_value!
- define_variable!
- primitive_procedure_p
- apply_primitive_procedure
- prompt_for_input
- announce_output
- user_print
- empty_arglist
- adjoin_arg
- last_operand_p
- no_more_exps_p
- get_global_environment

