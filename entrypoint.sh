#!/bin/bash
set -e

# Source ROS 2
source /opt/ros/humble/setup.bash

# Source workspace if built
if [ -f /ros2_ws/install/setup.bash ]; then
  source /ros2_ws/install/setup.bash
fi

# ── Foxglove Bridge Parameters ───────────────────────────────
# port              : WebSocket port Foxglove Studio connects to (default 8765)
# address           : Bind address
# max_qos_depth     : Increase QoS queue depth for high-throughput topics
# send_buffer_limit : Raise WebSocket send buffer to handle >60 Hz bursts

BRIDGE_PARAMS=(
  "--ros-args"
  "-p" "port:=8765"
  "-p" "address:=0.0.0.0"
  "-p" "max_qos_depth:=100"
  "-p" "send_buffer_limit:=10000000"   # 10 MB – prevents dropped frames at high Hz
  "-p" "num_threads:=4"                # parallel serialisation threads
)

# ── Optional: built-in high-frequency demo publisher ─────────
# Publishes std_msgs/Float64 at 200 Hz on /high_freq_topic.
# Replace or remove this block when using your own data source.
python3 - <<'PYEOF' &
import rclpy
from rclpy.node import Node
from std_msgs.msg import Float64
import time, math

class HiFreqPub(Node):
    def __init__(self):
        super().__init__('hi_freq_publisher')
        self.pub = self.create_publisher(Float64, '/high_freq_topic', 100)
        # 200 Hz  →  timer period = 0.005 s
        self.timer = self.create_timer(0.005, self.publish_cb)
        self.t0 = time.time()

    def publish_cb(self):
        msg = Float64()
        msg.data = math.sin(2 * math.pi * (time.time() - self.t0))
        self.pub.publish(msg)

rclpy.init()
node = HiFreqPub()
rclpy.spin(node)
PYEOF

PUBLISHER_PID=$!

# ── Launch Foxglove Bridge ────────────────────────────────────
echo "[entrypoint] Starting foxglove_bridge on port 8765 ..."
ros2 run foxglove_bridge foxglove_bridge "${BRIDGE_PARAMS[@]}" &
BRIDGE_PID=$!

# ── Graceful shutdown on SIGTERM / SIGINT ────────────────────
_shutdown() {
  echo "[entrypoint] Shutting down ..."
  kill "$PUBLISHER_PID" "$BRIDGE_PID" 2>/dev/null || true
  wait "$PUBLISHER_PID" "$BRIDGE_PID" 2>/dev/null
}
trap _shutdown SIGTERM SIGINT

wait "$BRIDGE_PID"
