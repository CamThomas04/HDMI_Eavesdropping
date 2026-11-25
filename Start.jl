using DSP, WAV, FFTW, Plots

# Given Load Function From Assignment 3
function load_iq(fn)
    len = div(filesize(fn), sizeof(ComplexF32))
    z = Vector{ComplexF32}(undef,len)
    read!(fn, z)
end;

# Load the first data file
z = load_iq("Recordings/scene3-640x480-60-350M-64M-40M.dat");

# -- First File Metadata --
# Centre Frequency
fc = 350e6
# Sampling Rate
fs = 64e6

# Pixel Clock Frequency
fp = 25.175e6

fp = 1.001fp

# First Five Frames of the Video Signal
xt = 800
yt = 525
num_frames = 5

# Interpolate and resample to the pixel clock frequency
z_resampled = resample(z, fp / fs)

# Try displaying the first frame
image = permutedims(reshape(abs.(z_resampled[1:xt*yt]), xt, yt))

#Translate over so the blanking intervals are at the right and bottom
aligned = circshift(image, (235, 215))

heatmap(aligned, color = :grays)
