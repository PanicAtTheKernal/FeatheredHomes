extends Task

class_name Condition

var bird: Bird
var reference: Variant
var value: Variant
var condition: Variant

# Structured as which bird property must pass the condition set by the bird
func _init(parent_bird: Bird, _refrence: Variant, _condiditon: Variant, node_name: String="Condition") -> void:
	super(node_name)
	bird = parent_bird
	reference = _refrence
	condition = _condiditon

func run() -> void:
	# This is base class thats meant to be extended
	match typeof(reference):
		TYPE_STRING:
			value = bird[reference]
		TYPE_CALLABLE:
			value = reference.call()

func start() -> void:
	super.start()
