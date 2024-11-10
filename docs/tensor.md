#Tensor class
[SOURCE CODE](https://github.com/Jersonrn/G-Mind/blob/master/godot/scripts/tensor.gd)


The Tensor class is the most important part of the [G-Mind](https://github.com/Jersonrn/G-Mind) framework. It stores values and gradient functions that will be applied to it during backpropagation.

*************************************************************

| Properties    |                                                                       |
| ------------- | --------------------------------------------------------------------- |
| values        | An array of values stored in the Tensor                               |
| grad_funcs    | An array of gradient functions that have been applied to the Tensor   |


| Methods                                           |
| ------------------------------------------------- |
| [new()](#tensornew)                               |
| _to_string()                                      |
| [add_grad_func()](#tensoradd_grad_func)           |
| [append()](#tensorappend)                         |
| [backward()](#tensorbackward)                     |
| [clear()](#tensorclear)                           |
| clear_grad_funcs()                                |
| get_shape()                                       |
| multiply()                                        |
| size()                                            |
| to_packedfloat32array()                           |
| ones_like()                                       |
| zeros_like()                                      |

*************************************************************

## **Tensor.new()**

Creates a new Tensor object


```gdscript
func _init(values_: Array = [], grad_funcs_: Array = []):
	self.values = values_
	self.grad_funcs = grad_funcs_
```


| Args          |                                                           |
| ------------- | --------------------------------------------------------- |
| values_       | An array of values to be stored in the Tensor             |
| grad_funcs_   | An array of gradient functions to be applied to the Tensor|


| Return                                    |
| ----------------------------------------- |
| A new instance of the [Tensor]() class    |

###Example

```gdscript
var tensor = Tensor.new([-1.4, 0.3, 0.9])
print(tensor)

# Output: Tensor(values=[-1.4, 0.3, 0.9])
```



*************************************************************
## **Tensor.add_grad_func()**

Adds a gradient function to the Tensor.


```gdscript
func add_grad_func(grad_func):
	self.grad_funcs.append(grad_func)
```

| Args          |                                               |
| ------------- | --------------------------------------------- |
| grad_func     | A gradient function to be added to the Tensor |


| Return                                        |
| --------------------------------------------- |
| null                                          |


###Example

```gdscript
func  _init():
	var tensor = Tensor.new([-1.4, 0.3, 0.9])
	var sigmoid = Sigmoid.new()

	var f32_array = tensor.to_packedfloat32array()

	f32_array = sigmoid.forward(f32_array)

	tensor = Tensor.new(
			f32_array,
			tensor.grad_funcs
		)
	tensor.add_grad_func(sigmoid)

	print(tensor.values)
	print(tensor.grad_funcs)

# Output:
# [0.19781611859798, 0.57444250583649, 0.7109494805336]
# [Sigmoid()]
```

*************************************************************
## **Tensor.append()**

Adds a value to the Tensor

```gdscript
func append(x):
	self.values.append(x)
```

| Args          |                                   |
| ------------- | --------------------------------- |
| x             | A value to be added to the Tensor |


| Return        |
| ------------- |
| null          |


###Example

```gdscript
# No example provided
```


*************************************************************
## **Tensor.backward()**

Performs backpropagation on the Tensor


```gdscript
func backward(batch_size_):
	assert(!self.grad_funcs.is_empty(),"No 'grad_funcs' found for this Tensor")

	var factor := float(1./batch_size_)

	var output: Tensor = self.grad_funcs[-1].calculate_derivative().ones_like()

	for idx in range(len(self.grad_funcs) - 1, -1, -1):
		var current_layer = self.grad_funcs[idx]

		if "gradients_w" in current_layer:
			#The length of the weights for each node in the current layer (len(self.weights[0 | 1 | ...n]))
			#matches the number of output nodes from the prev layer, which is precisely what we require at this point.
			var n_nodes_out_prev_layer = len(current_layer.weights[0])

			var derivative_weights := Tensor.new( current_layer.derivative_respect_weights() )
			var derivative_inputs := Tensor.new( current_layer.derivative_respect_inputs() )

			var new_total_derivative: Array = []

			for n_o_p_idx in range(n_nodes_out_prev_layer):
				var new_node_derivative : float = 0.0

				for n_o_c_idx in range(current_layer.out_features):
					var weight = derivative_inputs.values[n_o_c_idx][n_o_p_idx]
					var node_derivative = output.values[n_o_c_idx]

					new_node_derivative +=  weight * node_derivative 

					#Updating weights gradients
					var a = current_layer.gradients_w
					current_layer.gradients_w[n_o_c_idx][n_o_p_idx] += ( output.values[n_o_c_idx] * derivative_weights.values[n_o_p_idx] ) * factor

				new_total_derivative.append(new_node_derivative)

			#Updating bias gradients
			for n_o_idx in range(current_layer.out_features):
				current_layer.gradients_b[n_o_idx] += ( 1 * output.values[n_o_idx] ) * factor

			output.values = new_total_derivative
		else:
			var r = current_layer.calculate_derivative()
			var derivative_layer: Tensor = current_layer.calculate_derivative()
			output = output.multiply(derivative_layer)
```

| Args          |                                               |
| ------------- | --------------------------------------------- |
| batch_size_   | The batch size used for the backpropagation   |


| Return        |
| ------------- |
| null          |


###Example

```gdscript
func  _init():
	var tensor = Tensor.new([-1.4, 0.3, 0.9])
	var sigmoid = Sigmoid.new()

	var f32_array = tensor.to_packedfloat32array()

	f32_array = sigmoid.forward(f32_array)

	tensor = Tensor.new(
			f32_array,
			tensor.grad_funcs
		)
	tensor.add_grad_func(sigmoid)

	print(tensor.values)
	print(tensor.grad_funcs)

# Output:
# [0.19781611859798, 0.57444250583649, 0.7109494805336]
# [Sigmoid()]
```

*************************************************************
## **Tensor.clear()**

Clears the Tensor.


```gdscript
func clear():
	self.values.clear()
	self.grad_funcs.clear()
```

| Args          |                       |
| ------------- | --------------------- |
| None          |                       |


| Return        |
| ------------- |
| null          |


###Example

```gdscript
# No example provided
```
