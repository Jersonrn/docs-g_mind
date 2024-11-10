#Sequential class
[SOURCE CODE](https://github.com/Jersonrn/G-Mind/blob/master/godot/scripts/sequential.gd)


This class applies a sequence of operations in a consecutive manner

*************************************************************

| Properties    |                                                                       |
| ------------- | --------------------------------------------------------------------- |
| layers        | An Array that holds the operations to be applied                      |


| Methods                                               |                                                                   |
| ----------------------------------------------------- | ----------------------------------------------------------------- |
| [new()](#sequentialnew)                               | Creates a new Sequential object                                   |
| _to_string()                                          | Converts the Sequential object to a string representation         |
| [clip_gradients()](#sequentialclip_gradients)         | Clips the gradients of `self.layers` to a specified maximum norm  |
| [forward()](#sequentialforward)                       | Applies a sequence of operations to a Tensor                      |
| [gradients_to_zero()](#sequentialgradients_to_zero)   | Sets the gradients of all layers in `self.layers` to zero         |


*************************************************************

## **Sequential.new()**

Creates a new Sequential object


```gdscript
func _init( layers_: Array = [] ):
	self.layers = layers_
```


| Args          |                                       |
| ------------- | ------------------------------------- |
| layers_       | An array of operations to be applied  |


| Return                |
| --------------------- |
| A Sequential object   |



###Example

```gdscript
var Sequential.new([
	Dense.create(2, 15),
	LeakyRelu.new(),
])
```

*************************************************************

## **Sequential.clip_gradients()**

Clips the gradients of `self.layers` to a specified maximum norm


```gdscript
func clip_gradients(max_norm: float = 1.0):
	var norm = 0.

	for layer in layers:
		if "gradients_w" in layer:
			norm += layer.calculate_gradient_norm()
	
	if norm > max_norm:
		var factor = max_norm / norm

		for layer in layers:
			if "gradients_w" in layer:
				layer.normalize_gradients(factor)
```


| Args          |                                                                                                                           |
| ------------- | ------------------------------------------------------------------------------------------------------------------------- |
| max_norm      | The maximum allowed gradient norm. Gradients will be scaled down if the overall norm exceeds this value. Default is 1.0   |


| Return                |
| --------------------- |
| null                  |



###Example

```gdscript
```


*************************************************************

## **Sequential.forward()**

Apply a sequence of operations to a Tensor


```gdscript
func forward(x: Tensor) -> Tensor:
	var xx: Tensor = x.duplicate()
	
	for layer in self.layers:
		xx.values = layer.forward(PackedFloat32Array(xx.values))
		xx.add_grad_func(layer)

	return xx
```

| Args          |                                                                       |
| ------------- | --------------------------------------------------------------------- |
| x             | An [Tensor](./tensor.md) to which the operations will be applied      |


| Return                                                            |
| ----------------------------------------------------------------- |
| [Tensor](./tensor.md) resulting from the sequence of operations   |


###Example

```gdscript
```


*************************************************************

## **Sequential.gradients_to_zero()**

Sets the gradients of all layers in `self.layers` to zero


```gdscript
func gradients_to_zero():
	for layer in self.layers:
		if "gradients_w" in layer:
			layer.gradients_2_zero()
```

| Args  |       |
| ----- | ----- |
|       |       |


| Return                |
| --------------------- |
| null                  |


###Example

```gdscript
```


*************************************************************

## **Sequential.step()**

Applies the gradients to the weights of all layers in `self.layers` and optionally sets the gradients to zero


```gdscript
#apply_gradients
func step(learn_rate = 0.001, grad_to_zero: bool = false):
	for layer in self.layers:
		if "gradients_w" in layer:
			layer.apply_gradients(learn_rate, grad_to_zero)
```

| Args          |                                                                                                   |
| ------------- | ------------------------------------------------------------------------------------------------- |
| learn_rate    | The learning rate to be used for updating the weights. Default is 0.001                           |
| grad_to_zero  | If `true`, the gradients of all layers will be set to zero after the update. Default is `false`   |


| Return    |
| --------- |
| null      |


###Example

```gdscript
```
