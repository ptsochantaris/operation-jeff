# D - sand dunes: shape from shading.
#
# Brightness ~ slope along the light, so integrating it along the light gives
# height. The light travels at ~60 degrees (from the upper left, y down):
# measured by edge asymmetry - brightness drops sharply going that way, which on
# dunes is the crest (lit windward face -> shadowed slip face). The opposite
# sign turns every crest into a trough, so that test matters.
import sys, math
import numpy as np
from scipy import ndimage
from hmlib import *

LIGHT = 60
MARGIN = 22          # stay clear of the frame and the darkened outer pixels


def sfs(lum, angle_deg, blur=3.0, lowcut=0.012, eps=0.008):
    s = ndimage.gaussian_filter(lum, blur)
    s = s - s.mean()
    # mirror to 2x2 so the FFT sees a seamless periodic image
    m = np.block([[s, s[:, ::-1]], [s[::-1, :], s[::-1, ::-1]]])
    H, W = m.shape
    fy = np.fft.fftfreq(H)[:, None]
    fx = np.fft.fftfreq(W)[None, :]
    th = math.radians(angle_deg)
    dot = fx * math.cos(th) + fy * math.sin(th)
    # integrate along the light; eps damps the directions it says nothing about
    Z = np.fft.fft2(m) * (-1j * dot) / (2 * math.pi * (dot ** 2 + eps ** 2))
    r = np.sqrt(fx ** 2 + fy ** 2)
    Z *= 1 - np.exp(-(r / lowcut) ** 2)     # drop integration drift
    Z[0, 0] = 0
    return np.real(np.fft.ifft2(Z))[:s.shape[0], :s.shape[1]]


def screen_heights(maxz=14):
    _, a = load_art("D")
    inner = sfs(luminance(a)[MARGIN:256 - 4, MARGIN:320 - 4], LIGHT)
    z = np.pad(inner, ((MARGIN, 4), (MARGIN, 4)), mode="edge")
    z -= np.percentile(z, 2)
    return (z / np.percentile(z, 99.5) * maxz).clip(0, maxz)


def generate(maxz=14):
    z = screen_heights(maxz)
    return quantise(ndimage.gaussian_filter(to_cells(to_ground(z)), 0.6))
