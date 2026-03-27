# High-Frequency WS Connection Setup

A Dockerized [Foxglove Bridge](https://github.com/foxglove/ros-foxglove-bridge) for ROS 2 Humble that streams topics at **>60 Hz** over WebSocket to [Lichtblick](https://github.com/Lichtblick-Suite/lichtblick).

---

## 🚀 Quick Start

```bash
# Default (100 Hz & 1 topic)
bash create_ws_connection.sh

# Custom frequency
bash create_ws_connection.sh --frequency=500
bash create_ws_connection.sh -f=500

# Custom number of topics
bash create_ws_connection.sh --num-topics=5
bash create_ws_connection.sh -n=5

# Then open Lichtblick and connect to:
ws://localhost:8765
```

Subscribe to `/high_freq_topic_{topic-number}` to see the built-in sine wave demo.

_**NOTE:** Container will remove itself on exit._

---

## ⚙️ Available Flags

| Flag | Short | Default | Description |
|---|---|---|---|
| `--help` | `-h` | — | Explains how to use the commands |
| `--frequency` | `-f` | `200` | Publisher frequency in Hz |
| `--num-topics` | `-n` | `1` | Number of topics to publish |

---

## Plot panel topics

Added dummy four dummy waveforms at a fixed rate so the Lichtblick Plot panel always has something to visualise.

All topics use `std_msgs/Float64`. Add `<topic>.data` as the message path in the Plot panel.

| Topic | Signal | Range |
|---|---|---|
| `/plot_test/sine` | sin(2π t) | –1 … 1 |
| `/plot_test/cosine` | cos(2π t) | –1 … 1 |
| `/plot_test/sawtooth` | Sawtooth, period 1 s | –1 … 1 |
| `/plot_test/square` | Square wave, period 1 s | –1 or 1 |

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

---

## 📝 Notes

- Default WebSocket port is `8765`. Change it via the `port` param in `entrypoint.sh`.
- Set `ROS_DOMAIN_ID` in `docker-compose.yml` to match your ROS network if needed.
- For topics faster than ~500 Hz, consider enabling ROS 2 shared memory transport (Iceoryx).