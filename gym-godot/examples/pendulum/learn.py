import gym
from gym import spaces
from gym.wrappers import TimeLimit
from stable_baselines3.common.monitor import Monitor
from stable_baselines3 import DDPG
import numpy as np
import os
import gym_server

# Create env

# Server
serverIP = '127.0.0.1'
serverPort = '8000'

# Executable
projectPath = os.getcwd()[:-17]  # project.godot folder
godotPath = 'flatpak run org.godotengine.Godot'  # godot editor executable
scenePath = './examples/pendulum/Root.tscn'  # env Godot scene
exeCmd = 'cd {} && {} {}'.format(projectPath, godotPath, scenePath)

# Action Space : one float : torque force
action_space = spaces.Box(low=-2, high=2, shape=(1,), dtype=np.float32)

# Observation Space : three floats : cos theta, sin theta and angular speed
limit = np.array([1., 1., 2], dtype=np.float32)
observation_space = spaces.Box(low=-limit, high=limit, dtype=np.float32)

# Create folder to store renders
renderPath = os.getcwd() + '/render_frames/'
if not os.path.exists(renderPath):
    os.makedirs(renderPath)
else:
    # clean folder if not empty
    for file in os.scandir(renderPath):
        os.remove(file.path)

# Create gym-server with those parameters
env = gym.make('server-v0', serverIP=serverIP, serverPort=serverPort, exeCmd=exeCmd,
               action_space=action_space, observation_space=observation_space,
               window_render=False, renderPath=renderPath)

# Add a time limit + a tensorboard logger
env = Monitor(TimeLimit(env, max_episode_steps=250))

# Train
model = DDPG('MlpPolicy', env, verbose=0, tensorboard_log='./tensorboard_logs/',
            device='cpu', seed=0)
model.learn(total_timesteps=100000)

# Save to disk & load
model.save('pendulum_model')
model = DDPG.load('pendulum_model', device='cpu')

# Record one episode
obs = env.reset()
for i in range(250):
    action, _states = model.predict(obs)
    obs, rewards, done, info = env.step(action)
    env.render()
    if done:
        break
env.close()

# Create video from frames
os.system('cd {} && ffmpeg -hide_banner -loglevel error -framerate 30 -y -i %01d.png -vcodec libvpx video.webm'.format(renderPath))

# Remove frames
for item in os.listdir(renderPath):
    if item.endswith('.png'):
        os.remove(os.path.join(renderPath, item))
