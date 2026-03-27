import rclpy
from rclpy.node import Node
from std_msgs.msg import Float64
import time, math

PUBLISH_RATE_HZ = 10.0

class PlotTestPub(Node):
    """
    Publishes four dummy waveforms at a fixed rate so the Lichtblick Plot
    panel always has something to visualise.

    Topics (all std_msgs/Float64):
        /plot_test/sine      – sin(2π t)
        /plot_test/cosine    – cos(2π t)
        /plot_test/sawtooth  – sawtooth with period 1 s  (range –1 … 1)
        /plot_test/square    – square wave with period 1 s (–1 or 1)

    In the Plot panel add a series and set the message path to e.g.
        /plot_test/sine.data
    """

    def __init__(self):
        super().__init__('plot_test_publisher')
        self.t0 = time.time()

        self._pubs = {
            'sine':     self.create_publisher(Float64, '/plot_test/sine',     10),
            'cosine':   self.create_publisher(Float64, '/plot_test/cosine',   10),
            'sawtooth': self.create_publisher(Float64, '/plot_test/sawtooth', 10),
            'square':   self.create_publisher(Float64, '/plot_test/square',   10),
        }

        self.create_timer(1.0 / PUBLISH_RATE_HZ, self._publish_cb)
        self.get_logger().info(
            f'PlotTestPub started at {PUBLISH_RATE_HZ} Hz. '
            'Add /plot_test/<wave>.data to the Lichtblick Plot panel.'
        )

    def _publish_cb(self):
        t = time.time() - self.t0
        phase = 2.0 * math.pi * t          # one full cycle per second

        sine_msg     = Float64(); sine_msg.data     = math.sin(phase)
        cosine_msg   = Float64(); cosine_msg.data   = math.cos(phase)
        sawtooth_msg = Float64(); sawtooth_msg.data = 2.0 * (t % 1.0) - 1.0
        square_msg   = Float64(); square_msg.data   = 1.0 if math.sin(phase) >= 0.0 else -1.0

        self._pubs['sine'].publish(sine_msg)
        self._pubs['cosine'].publish(cosine_msg)
        self._pubs['sawtooth'].publish(sawtooth_msg)
        self._pubs['square'].publish(square_msg)


def main():
    rclpy.init()
    node = PlotTestPub()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == '__main__':
    main()
