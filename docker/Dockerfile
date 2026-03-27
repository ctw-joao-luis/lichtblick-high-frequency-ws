FROM ros:humble-ros-base-jammy

# ── System dependencies ──────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-colcon-common-extensions \
    git \
    && rm -rf /var/lib/apt/lists/*

# ── Build foxglove_bridge from foxglove-sdk (ROS 2 bridge) ───
# foxglove/ros-foxglove-bridge was converted to ROS 1 only.
# The ROS 2 bridge now lives in foxglove/foxglove-sdk.
RUN git clone --depth 1 https://github.com/foxglove/foxglove-sdk.git /tmp/foxglove-sdk

WORKDIR /ros2_ws
RUN mkdir -p src && \
    cp -r /tmp/foxglove-sdk/ros/src/. src/ && \
    rm -rf /tmp/foxglove-sdk

RUN apt-get update && \
    . /opt/ros/humble/setup.sh && \
    rosdep update && \
    rosdep install --from-paths src --ignore-src -y --rosdistro humble && \
    colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release && \
    rm -rf build log /var/lib/apt/lists/*

# ── Environment ──────────────────────────────────────────────
ENV ROS_DOMAIN_ID=0
ENV RCUTILS_LOGGING_MIN_SEVERITY=INFO

# ── Workspace ────────────────────────────────────────────────
WORKDIR /ros2_ws

# ── Entrypoint script ────────────────────────────────────────
COPY /entrypoint.sh /entrypoint.sh
COPY /python/HiFreqPub.py /python/HiFreqPub.py
COPY /python/PlotTestPub.py /python/PlotTestPub.py
RUN chmod +x /entrypoint.sh

EXPOSE 8765

ENTRYPOINT ["/entrypoint.sh"]
