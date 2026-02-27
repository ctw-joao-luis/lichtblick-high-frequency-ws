# Foxglove Bridge — High-Frequency Docker Setup

A Dockerized [Foxglove Bridge](https://github.com/foxglove/ros-foxglove-bridge) for ROS 2 Humble that streams topics at **>60 Hz** over WebSocket to [Lichtblick](https://github.com/Lichtblick-Suite/lichtblick).


---

## 📦 What's Inside

| File | Purpose |
|---|---|
| `Dockerfile` | Builds the ROS 2 Humble image with `foxglove_bridge` installed |
| `entrypoint.sh` | Launches the bridge + an optional 200 Hz demo publisher |
| `docker-compose.yml` | Convenience wrapper with host networking and IPC settings |

---

## 🚀 Quick Start

```bash
# Build and run
docker compose up --build

# Then open Lichtblick and connect to:
ws://localhost:8765
```

Subscribe to `/high_freq_topic` to see the built-in 200 Hz sine wave demo.

---

## ⚙️ High-Frequency Tuning

The bridge is pre-configured for high-throughput streaming:

- **`send_buffer_limit: 10 MB`** — prevents frame drops under WebSocket backpressure
- **`max_qos_depth: 100`** — keeps messages in queue between publish and serialization
- **`num_threads: 4`** — parallel serialization to keep up with fast topics
- **`network_mode: host` + `ipc: host`** — enables ROS 2 DDS discovery and zero-copy shared memory

---

## 🔧 Using Your Own Data Source

Replace the demo publisher block in `entrypoint.sh` with your own node or launch command:

```bash
# Example: launch your own node instead of the demo publisher
ros2 launch my_package my_launch.py &
```

To build a custom ROS 2 package into the image, uncomment these lines in the `Dockerfile`:

```dockerfile
COPY src/ /ros2_ws/src/
RUN . /opt/ros/humble/setup.sh && colcon build --symlink-install
```

---

## 📝 Notes

- Default WebSocket port is `8765`. Change it via the `port` param in `entrypoint.sh`.
- Set `ROS_DOMAIN_ID` in `docker-compose.yml` to match your ROS network if needed.
- For topics faster than ~500 Hz, consider enabling ROS 2 shared memory transport (Iceoryx).
