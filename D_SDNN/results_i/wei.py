import numpy as np
from scipy import io as spio
weights = np.load("weight[3]_5000.npy")
sz=weights.shape
print(sz)
print(weights )
spio.savemat('weight[3]_5000_41.mat', weights)