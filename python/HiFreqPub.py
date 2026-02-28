import rclpy
from rclpy.node import Node
from std_msgs.msg import Float64
import time, math
import argparse

class HiFreqPub(Node):
    def __init__(self, messageFrequency, num_topics):
        super().__init__('hi_freq_publisher')
        self.t0 = time.time()
        self.topic_publishers = []
        for i in range(num_topics):
            self.pub = self.create_publisher(Float64, f'/high_freq_topic_{i}', 100)
            self.topic_publishers.append(self.pub)
        self.timer = self.create_timer(self.calculate_freq(messageFrequency), self.publish_cb)

    def publish_cb(self):
        msg = Float64()
        msg.data = math.sin(2 * math.pi * (time.time() - self.t0))
        for pub in self.topic_publishers:
            pub.publish(msg)
    
    def calculate_freq(self, frequency):
        return 1 / frequency


parser = argparse.ArgumentParser()
parser.add_argument("-f", "--frequency", type=float, help="Frequency of messages in Hz", default=100.0)
parser.add_argument("-n", "--num-topics", type=int, help="Number of topics to publish", default=1)
args = parser.parse_args()

rclpy.init()
node = HiFreqPub(args.frequency, args.num_topics)
rclpy.spin(node)