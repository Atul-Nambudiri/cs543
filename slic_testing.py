from skimage.segmentation import slic
import numpy as np
import matplotlib.pyplot as plt
from scipy import misc, spatial


img = misc.imread('10081.jpg')

segments = slic(img, n_segments=25, compactness=25)
plt.imshow(segments)

plt.show()
