#MSELoss class
[SOURCE CODE](https://github.com/Jersonrn/G-Mind/blob/master/godot/scripts/mse_loss.gd)

The MSE Loss is a measure of the average squeared difference between the predited values $y$ and the target values $\hat{y}$


$$\text{MSE} = \frac{1}{n}\sum_{i=1}^{n} (y_i - \hat{y}_i)^2$$



*************************************************************

| Properties    |                                               |
| ------------- | --------------------------------------------- |
| outputs       | An float value representing the MSE loss      |
| y             | An [Tensor]() containing the target values    |
| y_hat         | An [Tensor]() containing the predicted values |


| Methods                                                   |                                                                                               |
| --------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| [new()](#mselossnew)                                      | Initializes a new instance of the MSELoss class                                               |
| _to_string()                                              | Converts the MSELoss object to a string representation                                        |
| [forward()](#mselossforward)                              | Calculates the mean squared error (MSE) between the predicted values and the target values    |
| [calculate_derivative()](#mselosscalculate_derivative)    | Calculates the derivative of the MSE loss with respect to the predicted values                |


*************************************************************

## **MSELoss.new()**

Initializes a new instance of the MSELoss class


```gdscript
func _init():
	pass
```


| Args      |           |
| --------- | --------- |
| None      |           |


| Return                                |
| ------------------------------------- |
| A new instance of the MSELoss class   |



###Example

```gdscript
var mse_loss = MSELoss.new()
```


*************************************************************

## **MSELoss.forward()**

Calculates the mean squared error (MSE) between the predicted values $\hat{y}$ and the target values $y$


```gdscript
func forward(y_hat_: Tensor, y_: Tensor) -> Tensor:
	self.y_hat = y_hat_; self.y = y_

	assert(self.y_hat.size() == self.y.size(), "The sizes of 'y_hat' and 'y' must be equal")

	var output:= Tensor.new([self.outputs], self.y_hat.grad_funcs.duplicate())
	var loss: float = 0.0

	for idx in range(len(self.y_hat.values)):
		loss += ( self.y_hat.values[idx] - self.y.values[idx] ) ** 2

	self.outputs = loss / y.size()

	output.values = Array([self.outputs])
	output.add_grad_func(self)

	return output
```


| Args          |                                           |
| ------------- | ----------------------------------------- |
| y_hat_        | A Tensor containing the predicted values  |
| y_            | A Tensor containing the target values     |


| Return                                                                        |
| ----------------------------------------------------------------------------- |
| A Tensor containing the average squared difference between `y_hat_` and `y_`  |



###Example

```gdscript
var y =     Tensor.new([0.3, 0.9, 0.3])
var y_hat = Tensor.new([0.9, 0.8, 0.3])

var mse_loss = MSELoss.new()

var loss = mse_loss.forward(y_hat, y)

func _init():
	print(loss)

# Output: Tensor(values=[0.12333333333333])
```


*************************************************************

## **MSELoss.calculate_derivative()**

Calculates the derivative of the MSE Loss with respect to the predicted values. This is used during backpropagation


$$ \frac{\partial \text{MSE}}{\partial \hat{y}_i} = 2 (\hat{y}_i - y_i) $$


```gdscript
func calculate_derivative() -> Tensor:
	var output := Tensor.new()

	for idx in range(len(self.y_hat.values)):
		output.append( 2 * (self.y_hat.values[idx] - self.y.values[idx]) )
	
	return output
```

This method calculates the derivative for each individual predicted value, rather than the average derivative

$$ \frac{\partial \text{MSE}}{\partial \hat{y}} = \frac{2}{n} \sum_{i=1}^{n} (\hat{y}_i - y_i) $$


| Args  |       |
| ----- | ----- |
| None  |       |


| Return                                                                                            |
| ------------------------------------------------------------------------------------------------- |
| A Tensor object containing the derivatives of the MSE loss with respect to each predicted value   |



###Example

```gdscript
# No example provided
```
