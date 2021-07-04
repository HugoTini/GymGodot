import gym
from gym import spaces
import numpy as np
import asyncio
import websockets
from multiprocessing import Pipe, Process
from threading import Thread
import json
import subprocess


class ServerEnv(gym.Env):

    def __init__(self, serverIP='127.0.0.1', serverPort='8000', 
                 exeCmd=None, action_space=None, observation_space=None, proc_mode='process',
                 window_render=False, env_fps=60, renderPath='./render_frames/'):
        # Server url
        self.serverIP = serverIP
        self.serverPort = serverPort

        # Action & observation space
        self.action_space = action_space
        self.observation_space = observation_space

        # Render frames path
        self.renderPath = renderPath

        # Pipe to send/get msg from the server process
        self.parent_conn, self.child_conn = Pipe()

        # Start the websocket server process
        assert ((proc_mode=='thread' or proc_mode=='process'))
        print('- starting Gym server')
        if proc_mode == 'thread' :
            self.p = Thread(target=self._start_server)
        elif proc_mode == 'process':
            self.p = Process(target=self._start_server)
        self.p.start()

        # Start the simulation
        physic_delta_flag = ' --fixed-fps {}'.format(env_fps)
        render_loop_flag = ' --disable-render-loop' if not window_render else ''
        server_ip_flag = ' --serverIP={}'.format(serverIP)
        server_port_flag = ' --serverPort={}'.format(serverPort)
        render_path_flag = ' --renderPath={}'.format(renderPath)
        flags = physic_delta_flag + render_loop_flag + server_ip_flag + server_port_flag + render_path_flag
        print('- starting Godot env with command : ' + exeCmd + flags)
        subprocess.Popen([exeCmd + flags], shell=True)

    def _start_server(self):
        # Run server logic on process loop
        self.loop = asyncio.new_event_loop()
        asyncio.set_event_loop(self.loop)
        ws_server = websockets.serve(self._server_handler, self.serverIP, self.serverPort)
        self.loop.run_until_complete(ws_server)
        self.loop.run_forever()
    
    async def _server_handler(self, websocket, path):
        while True:
            # Block until there is a msg to send and read it
            msg = self.child_conn.recv() 
            # Wait for the msg to be sent
            await websocket.send(json.dumps(msg))
            # If msg is not a 'close' msg then wait for the answer, otherwise stop the server
            if msg['cmd'] != 'close' :
                try:
                    answer = await websocket.recv()  
                except:
                    print('- connection ended')
                    break
                # Parse answer
                answer = json.loads(answer)
                # Send the answer back to main process
                self.child_conn.send(answer)
            else :
                break
        self.loop.call_soon_threadsafe(self.loop.stop)

    def _sendAndGetAnswer(self, msg):
        # Send msg to server process
        self.parent_conn.send(msg)
        # Block until answer available 
        return self.parent_conn.recv()

    def reset(self):    
        # Send reset msg and return initial observation
        answer = self._sendAndGetAnswer({'cmd': 'reset'})
        return np.array(answer['init_observation']).astype(np.float32)

    def step(self, action):
        # Send action msg and return current obs, reward and isDone
        if isinstance(self.action_space, spaces.Discrete):
            action = np.asarray([action])  # Handle discrete space
        answer = self._sendAndGetAnswer(
            {'cmd': 'step', 'action': action.tolist()})
        observation_np = np.array(answer['observation']).astype(np.float32)
        return observation_np, answer['reward'], answer['done'], {}

    def close(self):
        # Send close msg
        self.parent_conn.send({'cmd': 'close'})
        # Wait for server to close
        self.p.join()
        print('- server closed')

    def render(self, mode=''):
        # Send render msg
        answer = self._sendAndGetAnswer({'cmd': 'render'})
        # Report Godot render error if any
        if answer['render_error'] != '0':
            print('Error while saving render : ' + answer['render_error'])
