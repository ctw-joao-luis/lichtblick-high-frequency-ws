#!/bin/bash
set -e

# Default frequency
FREQUENCY=${FREQUENCY}

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
python3 /python/HiFreqPub.py --frequency $FREQUENCY &

PUBLISHER_PID=$!

# ── Launch Foxglove Bridge ────────────────────────────────────
echo "[entrypoint] Starting foxglove_bridge on port 8765 ..."
echo "[entrypoint] Publishing demo data at ${FREQUENCY} Hz on /high_freq_topic ..."
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
