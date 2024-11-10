#Dense
[SOURCE CODE](https://github.com/Jersonrn/G-Mind/blob/master/rust/g-mind/src/dense.rs)

The Dense class represents a fully connected layer in a neural network


$$y = \mathbf{W} \mathbf{x} + \mathbf{b}$$

This applies a linear transformation


*************************************************************

| Properties    |                                           |
| ------------- | ----------------------------------------- |
| in_features   | The number of input features. Type: i8    |
| out_features  | The number of output features. Type: i8   |
| inputs        | An PackedFloat32Array of input values     |
| outputs       | An PackedFloat32Array of output values    |
| weights       | An Array of PackedFloat32Arrays, representing the weight matrix|
| biases        | An PackedFloat32Array of bias values|
| gradients_w   | An Array of PackedFloat32Arrays, representing the gradients of the weights|
| gradients_b   | An PackedFloat32Array of gradients of the biases  |

| Methods                   |           |
| ------------------------- | --------- |
| [func()](#dense)          |           |
| [create()](#densecreate)  | Initializes a new instance of the Dense class |
| to_string()               | Returns a string representation of the Dense instance|
| [apply_gradients()](#denseapply_gradients)    | |
| [forward()](#denseforward)          |           |
| [calculate_gradient_norm()](#densecalculate_gradient_norm)          |           |
| [normalize_gradients()](#densenormalize_gradients)          |           |
| [set_randf_weights_bias_and_zero_gradients()](#denseset_randf_weights_bias_and_zero_gradients)          |           |
| [gradients_2_zero()](#densegradients_2_zero)          |           |
| [calculate_derivative()](#densecalculate_derivative)          |           |
| [derivative_respect_inputs()](#densederivative_respect_inputs)          |           |
| [derivative_respect_weights()](#densederivative_respect_weights)          |           |


*************************************************************
## **Dense.create()**

Initializes a new instance of the Dense class

```rust
    #[func]
    fn create(in_features_: i8, out_features_: i8) -> Gd<Dense> {
        Gd::from_init_fn(|base| {
            let mut dense_instance = Self {
                in_features: in_features_,
                out_features: out_features_,

                inputs: PackedFloat32Array::new(),
                outputs: PackedFloat32Array::new(),

                weights: array![],
                biases: PackedFloat32Array::new(),

                gradients_w: array![],
                gradients_b: PackedFloat32Array::new(),

                base,
            };
            dense_instance.set_randf_weights_bias_and_zero_gradients();

            dense_instance //return
        })
    }
```

| Args              |           |
| ----------------- | --------- |
| in_features_      | The number of input features  |
| out_features_     | The number of output features |


| Return                                |
| ------------------------------------- |
| A new instance of the [Dense]() class |



###Example

```gdscript
var dense = Dense.create(2, 15)
```


*************************************************************
## **Dense.apply_gradients()**

Applies the gradients to the `self.weights` and optionally sets the gradients to zero

<!-- <details> -->
```rust
    #[func]
    fn apply_gradients(&mut self, lr: f32, clean_grad: bool) {
        // TODO: The line "self.gradients_w.get(node_out_index).fill(0.)" doesn't work because "get" returns the value of an index and doesn't function like a "slice."
        // I've also encountered difficulty transforming a "vec" into a "Godot array."
        // Consequently, I found it necessary to create the variables:
        // [zero_layer_gradients_w, zero_layer_gradients_b, zero_node_gradients_w, zero_node_gradients_b].
        // I'll refine this as soon as I have the time and opportunity.

        let mut new_layer_weights: Array<PackedFloat32Array> = array![];
        let mut new_layer_biases = PackedFloat32Array::new();

        let mut zero_layer_gradients_w: Array<PackedFloat32Array> = array![];
        let mut zero_layer_gradients_b = PackedFloat32Array::new();

        for node_out_index in 0..self.weights.len() {
            let node_weights: PackedFloat32Array = self.weights.get(node_out_index);

            let mut new_node_weights = PackedFloat32Array::new();
            let mut new_node_biases = 0.;

            let mut zero_node_gradients_w = PackedFloat32Array::new();
            let mut zero_node_gradients_b = 0.;

            for node_in_index in 0..node_weights.len() {
                let weight = self.weights.get(node_out_index).get(node_in_index);
                let gradient_w = self.gradients_w.get(node_out_index).get(node_in_index);

                new_node_weights.push( weight - (gradient_w * lr) );
                zero_node_gradients_w.push(0.);
            };

            let bias = self.biases.get(node_out_index);
            let gradient_b = self.gradients_b.get(node_out_index);

            new_node_biases = bias - (gradient_b * lr);
            zero_node_gradients_b = 0.;


            new_layer_weights.push(new_node_weights);
            new_layer_biases.push(new_node_biases);

            zero_layer_gradients_w.push(zero_node_gradients_w);
            zero_layer_gradients_b.push(zero_node_gradients_b);

            // if clean_grad == true {
            //     self.gradients_w.get(node_out_index).fill(0.)
                
            // }
        };

        self.weights = new_layer_weights;
        self.biases = new_layer_biases;

        if clean_grad == true {
            self.gradients_w = zero_layer_gradients_w;
            self.gradients_b = zero_layer_gradients_b;
        }


        // if clean_grad == true {
        //     self.gradients_b.fill(0.);
        // }

    }
```
<!-- </details> -->

| Args              |           |
| ----------------- | --------- |
| lr                | The learning rate |
| clean_grad        | A boolean indicating whether to set the gradients to zero after applying them |


| Return    |
| --------- |
| null      |



###Example

```gdscript
```


*************************************************************
## **Dense.forward()**

Computes the output of the Dense layer for the given input


```rust
    #[func]
    fn forward(&mut self, x:PackedFloat32Array,) -> PackedFloat32Array {
        assert!(x.len() == self.in_features as usize, "Error: The size of the input data doesn't match the expected input features for the layer.");

        self.inputs = x;
        self.outputs = PackedFloat32Array::new();

        let mut output = PackedFloat32Array::new();

        for node_weights_index in 0..self.weights.len() {
            let node_weights = self.weights.get(node_weights_index);
            let mut node_output: f32 = 0.;

            for weight_index in 0..node_weights.len() {
                let weight: f32 = node_weights.get(weight_index);

                node_output += self.inputs.get(weight_index) * weight;
            }
            node_output += self.biases.get(node_weights_index);

            output.push(node_output);
        }
        self.outputs = output.clone();
        output
    }
```

| Args  |           |
| ----- | --------- |
| x     | An PackedFloat32Array of input values |


| Return                |
| --------------------- |
| An PackedFloat32Array of output values    |



###Example

```gdscript
```


*************************************************************
## **Dense.calculate_gradient_norm()**

Calculates the norm of the gradients


```rust
    #[func]
    fn calculate_gradient_norm(&mut self) -> f32 {
        let mut grad_norm: f32 = 0.;

        for i in 0..self.gradients_w.len(){
            let node_grad_weights: PackedFloat32Array = self.gradients_w.get(i);

            for j in 0..node_grad_weights.len() {
                let grad_weight: f32 = node_grad_weights.get(j);

                grad_norm += grad_weight * grad_weight;
                
            }

            let grad_bias: f32 = self.gradients_b.get(i);

            grad_norm += grad_bias * grad_bias;

        }

        grad_norm
        
    }
```

| Args  |           |
| ----- | --------- |
| None  |           |


| Return                |
| --------------------- |
| The norm of the gradients as a `f32` value    |



###Example

```gdscript
```

*************************************************************
## **Dense.normalize_gradients()**

TODO


```rust
    #[func]
    fn normalize_gradients(&mut self, factor: f32,) {
        let mut norm_grad_weights: Array<PackedFloat32Array> = Array::new();
        let mut norm_grad_biases: PackedFloat32Array = PackedFloat32Array::new();

        for i in 0..self.gradients_w.len() {
            let node_grad_weights: PackedFloat32Array = self.gradients_w.get(i);

            let mut norm_row_grads: PackedFloat32Array = PackedFloat32Array::new();  //row of the weights

            for j in 0..node_grad_weights.len() {
                let weight_grad: f32 = node_grad_weights.get(j);

                norm_row_grads.push(factor * weight_grad);
                
            }
            let bias_grad: f32 = self.gradients_b.get(i);

            norm_grad_weights.push(norm_row_grads);
            norm_grad_biases.push(factor * bias_grad)
            
        }
        self.gradients_w = norm_grad_weights;
        self.gradients_b = norm_grad_biases;
    }
```

| Args  |           |
| ----- | --------- |
| factor|           |


| Return                |
| --------------------- |
| null                  |



###Example

```gdscript
```


*************************************************************
## **Dense.set_randf_weights_bias_and_zero_gradients()**

TODO


```rust
    #[func]
    fn set_randf_weights_bias_and_zero_gradients(&mut self) {
        let mut rng = RandomNumberGenerator::new_gd();
        // rng.set_seed(4555);
        rng.randomize();
        // let seed = rng.get_seed();

        for out_features_index in 0..self.out_features {
            let mut node_out_weights: PackedFloat32Array = PackedFloat32Array::new();
            let mut row_gradients: PackedFloat32Array = PackedFloat32Array::new();

            for in_feature_index in 0..self.in_features {
                node_out_weights.push(rng.randf_range(-1., 1.));
                row_gradients.push(0.);
            }

            self.weights.push(node_out_weights);
            self.biases.push(rng.randf_range(-1., 1.));

            self.gradients_w.push(row_gradients);
            self.gradients_b.push(0.)
        }
        
    }
```

| Args  |           |
| ----- | --------- |
|       |           |


| Return                |
| --------------------- |
|                       |



###Example

```gdscript
```


*************************************************************
## **Dense.gradients_2_zero()**

TODO


```rust
    #[func]
    fn gradients_2_zero(&mut self) {
        let mut zero_weights_grad: Array<PackedFloat32Array> = Array::new();
        let mut zero_biases_grad: PackedFloat32Array = PackedFloat32Array::new();

        for out_features_index in 0..self.out_features {
            let mut row_gradients: PackedFloat32Array = PackedFloat32Array::new();

            for in_features_index in 0..self.in_features {
                row_gradients.push(0.);
                
            }
            zero_weights_grad.push(row_gradients);
            zero_biases_grad.push(0.)
            
        }
        self.gradients_w = zero_weights_grad;
        self.gradients_b = zero_biases_grad;
        
    }
```

| Args  |           |
| ----- | --------- |
|       |           |


| Return                |
| --------------------- |
|                       |



###Example

```gdscript
```

*************************************************************
## **Dense.calculate_derivative()**

TODO


```rust
    #[func]
    fn calculate_derivative(&self) -> Array<PackedFloat32Array> {
        self.weights.clone()
    }
```

| Args  |           |
| ----- | --------- |
|       |           |


| Return                |
| --------------------- |
|                       |



###Example

```gdscript
```

*************************************************************
## **Dense.derivative_respect_inputs()**

TODO


```rust
    #[func]
    fn derivative_respect_inputs(&self) -> Array<PackedFloat32Array> {
        self.weights.clone()
    }
```

| Args  |           |
| ----- | --------- |
|       |           |


| Return                |
| --------------------- |
|                       |



###Example

```gdscript
```


*************************************************************
## **Dense.derivative_respect_weights()**

TODO


```rust
    #[func]
    fn derivative_respect_weights(&self) -> PackedFloat32Array {
        self.inputs.clone()
    }
```

| Args  |           |
| ----- | --------- |
|       |           |


| Return                |
| --------------------- |
|                       |



###Example

```gdscript
```
