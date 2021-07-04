from gym.envs.registration import register

register(
    id='server-v0',
    entry_point='gym_server.envs:ServerEnv',
)
