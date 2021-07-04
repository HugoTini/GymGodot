# Message Protocol

## Gym (server) -> Godot (client)

`step(action)` :

	{
		'cmd': 'step',
		'action': <action space sample>
	}

`reset()`:

	{
		'cmd': 'reset'
	}

`render()`:

	{
		'cmd': 'render'
	}

`close()`:

	{
		'cmd': 'close'
	}

## Godot (client) -> Gym (server)

`step(action)` answer (which is the values for `observation`,
`reward` and `done` after having performed a step with the given
actions) :

	{
		'observation': <observation space sample>,
		'reward': <float>,
		'done': <bool>
	}

`reset()` answer (which is the initial observation of the space) :

	{
		'init_observation': <observation space sample>
	}

`render()` answer :

	{
		'render_error': <Godot Error Code>
	}

`close()` message does not expect any answer

# Action/Observation Space

A space object defines what are the actions / observations ranges (https://gym.openai.com/docs/#spaces). 

Spaces values are serialized to string and put in place of  `<observation space sample>` or `<action space sample>` in the JSON messages above.

## Discrete Space

`Discrete` (https://github.com/openai/gym/blob/master/gym/spaces/discrete.py)

Example : An agent has 4 possible actions 'go_up', 'go_down', 'go_left', 'go_right'. Then the action space of the environment would be  `env.action_space = spaces.Discrete(4)` and could take 4 possible int values : 1, 2, 3 or 4 (representing each action).

**Space Sample Type :**

- Gym (Python) : `int`
- Godot (GDScript) : `Array`
- Serialized example : a Python Discrete Space Sample of `2` will be converted to the string "`[2]`" and be received as the GDScript array `[2]`.


## Continuous Space

`Box` (https://github.com/openai/gym/blob/master/gym/spaces/box.py)

Example : For continuous values, we use a n-dimensional box where the ith dimension is in the range `(low[i],high[i])`. For instance, if we observe two float values, one in range `(0.0, 200.0)` and the other in range `(0.0, 10.0)`, it would be declared as : `env.observation_space = spaces.Box(low = np.array([0.0, 0.0]), high = np.array([200.0, 10.0]))`

**Space Sample Type :**

- Gym (Python) : `numpy.ndarray`
- Godot (GDScript) : `Array`
- Serialized example : a continuous 2D space sample of `np.array([2.3, 3.4])` will be converted to the string "`[2.3, 3.4]`" and received as the GDScript array `[2.3, 3.4]`.