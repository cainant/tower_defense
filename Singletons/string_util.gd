extends Node

func camel_to_snake_case(input: String) -> String:
	var regex = RegEx.new()
	regex.compile(r'(?<!^)(?=[A-Z0-9])')
	var result = regex.sub(input, "_", true)
	return result.to_lower()
