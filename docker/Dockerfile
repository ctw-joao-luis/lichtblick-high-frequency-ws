# ============================================================
# Foxglove Bridge - High Frequency Topic Streaming (>60Hz)
# Base: ROS 2 Humble on Ubuntu 22.04
# ============================================================
FROM ros:humble-ros-base-jammy

# ── System dependencies ──────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-foxglove-bridge \
    ros-humble-rosbridge-server \
    python3-pip \
    python3-colcon-common-extensions \
    && rm -rf /var/lib/apt/lists/*

# ── Environment ──────────────────────────────────────────────
ENV ROS_DOMAIN_ID=0
ENV RCUTILS_LOGGING_MIN_SEVERITY=INFO

# ── Workspace ────────────────────────────────────────────────
WORKDIR /ros2_ws

# ── Copy custom high-freq publisher package (optional) ───────
# Uncomment if you have a local ROS 2 package to build:
# COPY src/ /ros2_ws/src/
# RUN . /opt/ros/humble/setup.sh && colcon build --symlink-install

# ── Entrypoint script ────────────────────────────────────────
COPY /entrypoint.sh /entrypoint.sh
COPY /scripts/HiFreqPub.py /scripts/HiFreqPub.py
RUN chmod +x /entrypoint.sh

EXPOSE 8765

ENTRYPOINT ["/entrypoint.sh"]
