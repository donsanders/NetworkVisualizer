# NetworkVisualizer

Network topology visualizer written in swift

This is a for-fun project to explore network topologies and simulated environments

Current status: 

master branch HEAD is setup to produce the release video

dancing-nodes tag can beused to reproduce the dancing nodes

Even though the code doesn't use any random numbers the nodes behave differently
every time the code runs, I think this is because display link is used for timing

A righteous feeling came over me and I decided to write this code. I made a mistake
implementing gravity like inverse square forces and it causes the nodes to kind of
dance which I find entertaining so I thought others might like to see also.

## Usage

You'll need XCode to build and deploy the code, the project targets the iOS platform.

## Todo

Auto balance the repulsing and attracting forces in the universe automatically.

I've experimented with larger forces to simulate a more viscous (petri dish) or
solid like environment. But it becomes increasing tedious to manually balance the 
forces as they become larger.

## License

MIT (see LICENSE file).
