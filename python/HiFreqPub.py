import rclpy
from rclpy.node import Node
from std_msgs.msg import Float64
import time, math
import argparse

class HiFreqPub(Node):
    def __init__(self, messageFrequency):
        super().__init__('hi_freq_publisher')
        self.pub = self.create_publisher(Float64, '/high_freq_topic', 100)
        self.timer = self.create_timer(self.calculate_freq(messageFrequency), self.publish_cb)
        self.t0 = time.time()

    def publish_cb(self):
        msg = Float64()
        msg.data = math.sin(2 * math.pi * (time.time() - self.t0))
        self.pub.publish(msg)
    
    def calculate_freq(self, frequency):
        return 1 / frequency


parser = argparse.ArgumentParser()
parser.add_argument("-f", "--frequency", type=float, help="Frequency of messages in Hz", default=200.0)
args = parser.parse_args()

rclpy.init()
node = HiFreqPub(args.frequency)
rclpy.spin(node)