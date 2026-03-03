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

# ── Entrypoint script ────────────────────────────────────────
COPY /entrypoint.sh /entrypoint.sh
COPY /python/HiFreqPub.py /python/HiFreqPub.py
RUN chmod +x /entrypoint.sh

EXPOSE 8765

ENTRYPOINT ["/entrypoint.sh"]
