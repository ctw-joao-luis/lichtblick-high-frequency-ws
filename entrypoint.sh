#!/bin/bash
set -e

# Default frequency
FREQUENCY=${FREQUENCY}
NUM_TOPICS=${NUM_TOPICS}

# Source ROS 2
source /opt/ros/humble/setup.bash

# Source workspace if built
if [ -f /ros2_ws/install/setup.bash ]; then
  source /ros2_ws/install/setup.bash
fi

# ── Optional: built-in demo publishers ──────────────────────
# Replace or remove this block when using your own data source.
python3 /python/HiFreqPub.py --frequency $FREQUENCY --num-topics $NUM_TOPICS &
HIFREQ_PID=$!
python3 /python/PlotTestPub.py &
PLOT_PID=$!

# ── Launch Foxglove Bridge ────────────────────────────────────
echo "[entrypoint] Starting foxglove_bridge on port 8765 ..."
echo "[entrypoint] Publishing demo data at ${FREQUENCY} Hz on ${NUM_TOPICS} topic(s) ..."
ros2 launch foxglove_bridge foxglove_bridge_launch.xml \
    port:=8765 \
    address:=0.0.0.0 \
    max_qos_depth:=100 \
    send_buffer_limit:=10000000 \
    num_threads:=4 &
BRIDGE_PID=$!

# ── Graceful shutdown on SIGTERM / SIGINT ────────────────────
_shutdown() {
  echo "[entrypoint] Shutting down ..."
  kill "$HIFREQ_PID" "$PLOT_PID" "$BRIDGE_PID" 2>/dev/null || true
  wait "$HIFREQ_PID" "$PLOT_PID" "$BRIDGE_PID" 2>/dev/null
}
trap _shutdown SIGTERM SIGINT

wait "$BRIDGE_PID"
