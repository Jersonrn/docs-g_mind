#ReduceLROnPlateau
[SOURCE CODE](https://github.com/Jersonrn/G-Mind/blob/master/godot/scripts/reduce_lr_on_plateau.gd)

The ReduceLROnPlateau technique dynamically reduces the learning rate during training when the model's performance stops improving


*************************************************************

| Properties        |                                               |
| ----------------- | --------------------------------------------- |
| patience          | An integer value that determines the number of epochs to wait before reducing the learning rate if the metric has not improved    |
| mode              | Specifies whether the metric being monitored is a maximization or minimization problem. The possible values are `Modes.MAX` for maximization and `Modes.MIN` for minimization |
| factor            | A float value that determines the factor by which the learning rate will be reduced. The new learning rate will be the current learning rate multiplied by this factor        |
| threshold         | A float value that determines the minimum change in the monitored metric required to be considered an improvement                 |
| num_bad_epochs    | An integer value that keeps track of the number of epochs where the metric has not improved                                       |
| cooldown          | An integer value that determines the number of epochs to wait before resuming normal operation after a learning rate reduction    |
| min_lr            | A float value that determines the minimum learning rate allowed. The learning rate will not be reduced below this value           |
| verbose           | A boolean value that determines whether to print messages about the learning rate reduction process                               |
| cooldown_counter  | An integer value that keeps track of the current cooldown period                                                                  |
| best              | A float value that stores the best value of the monitored metric so far                                                           |



| Methods                                           |
| ------------------------------------------------- |
| [new()](#reducelronplateaunew)                    |
| [is_better()](#reducelronplateauis_better)        |
| [in_cooldown()](#reducelronplateauin_cooldown)    |
| [reset()](#reducelronplateaureset)                |
| [step()](#reducelronplateaustep)                  |
| [worse()](#reducelronplateauworse)                |



*************************************************************

## **ReduceLROnPlateau.new()**

Initializes a new instance of the ReduceLROnPlateau class


```gdscript
func _init(
		_patience: int = 5,
		_mode: String = "max",
		_factor: float = 0.1,
		_threshold: float = 0.1,
		_num_bad_epochs: int = 0,
		_cooldown: int = 0,
		_min_lr: float = 0.000001,
		_verbose: bool = false,
	):
	self.patience = _patience
	if _mode == "max":
		self.mode = self.Modes.MAX
	elif _mode == "min":
		self.mode = self.Modes.MIN
	else:
		push_error("Unknown mode for scheduler ReduceLROnPlateau, please use 'max' or 'min'")
	self.factor = _factor
	self.threshold = _threshold
	self.num_bad_epochs = _num_bad_epochs
	self.best = self.worse()
	self.cooldown = _cooldown
	self.min_lr = _min_lr
	self.verbose = _verbose

	self.cooldown_counter = self.cooldown
```

| Args              |           |
| ----------------- | --------- |
| _patience         |  An integer value that determines the number of epochs to wait before reducing the learning rate if the metric has not improved   |
| _mode             | A string value that specifies whether the metric being monitored is a maximization or minimization problem. The possible values are "max" for maximization and "min" for minimization |
| _factor           | A float value that determines the factor by which the learning rate will be reduced   |
| _threshold        | A float value that determines the minimum change in the monitored metric required to be considered an improvement |
| _num_bad_epochs   | An integer value that keeps track of the number of epochs where the metric has not improved   |
| _cooldown         | An integer value that determines the number of epochs to wait before resuming normal operation after a learning rate reduction    |
| _min_lr           | A float value that determines the minimum learning rate allowed   |
| _verbose          | A boolean value that determines whether to print messages about the learning rate reduction process   |


| Return                                            |
| ------------------------------------------------- |
| A new instance of the ReduceLROnPlateau class     |



###Example

```gdscript
var scheduler = ReduceLROnPlateau.new(
		5,			#patience
		"min",		#mode
		0.001,		#factor
		0.0001,		#threshold
		0,			#num_bad_epochs
		0,			#cooldown
		0.000001,	#min_lr
		true		#verbose
	)
```

*************************************************************

## **ReduceLROnPlateau.is_better()**

Checks if the current metric value is better than the best value so far, based on the specified mode (maximization or minimization)


```gdscript
func is_better(current):
	if self.mode == self.Modes.MAX:
		return current > self.best + self.threshold
	elif self.mode == self.Modes.MIN:
		return current < self.best - self.threshold
	else:
		push_error("Unknow mode for scheduler ReduceLROnPlateau")
```


| Args      |                           |
| --------- | ------------------------- |
| current   | The current metric value  |


| Return                                                                                            |
| ------------------------------------------------------------------------------------------------- |
| A boolean value indicating whether the current metric value is better than the best value so far  |

###Example

```gdscript
```


*************************************************************

## **ReduceLROnPlateau.in_cooldown()**

Checks if the scheduler is currently in a cooldown period


```gdscript
func in_cooldown():
	return self.cooldown_counter > 0
```


| Args      |               |
| --------- | ------------- |
| None      |               |


| Return                                                                    |
| ------------------------------------------------------------------------- |
| A boolean value indicating whether the scheduler is in a cooldown period  |

###Example

```gdscript
```


*************************************************************

## **ReduceLROnPlateau.reset()**

Resets the `self.num_bad_epochs` and `self.cooldown_counter` properties


```gdscript
func reset():
	self.num_bad_epochs = 0
	self.cooldown_counter = 0
```


| Args      |               |
| --------- | ------------- |
| None      |               |


| Return    |
| --------- |
| null      |

###Example

```gdscript
```

*************************************************************

## **ReduceLROnPlateau.step()**

Updates the learning rate based on the provided metric value and the current state of the scheduler


```gdscript
func step(metrics, lr) -> float:
	if self.in_cooldown():
		self.cooldown_counter -= 1
	else:
		if self.is_better(metrics):
			self.best = metrics
			self.num_bad_epochs = 0
		else:
			self.num_bad_epochs += 1

	if self.num_bad_epochs > self.patience:
		self.cooldown_counter = self.cooldown
		self.num_bad_epochs = 0

		var new_lr = lr - self.factor

		if new_lr < self.min_lr:
			if verbose:
				print("Min lr reached ", self.min_lr)
			return self.min_lr

		if verbose:
			print("Reducing learning rate to ", new_lr)
		return new_lr
	else:
		return lr
```


| Args      |                           |
| --------- | ------------------------- |
| metrics   | The current metric value  |
| lr        | The current learning rate |


| Return                                    |
| ----------------------------------------- |
| A float with the updated learning rate    |

###Example

```gdscript
```


*************************************************************

## **ReduceLROnPlateau.worse()**

Returns the initial "worst" value for the monitored metric, based on the specified mode (maximization or minimization)


```gdscript
func worse() -> float:
	if self.mode == self.Modes.MAX:
		return 0.0
	else:
		return 1000000.0
```


| Args      |               |
| --------- | ------------- |
| None      |               |


| Return                                                |
| ----------------------------------------------------- |
| The initial "worst" value for the monitored metric    |

###Example

```gdscript
```

