using DSP, WAV, FFTW, Plots

# Given Load Function From Assignment 3
function load_iq(fn)
    len = div(filesize(fn), sizeof(ComplexF32))
    z = Vector{ComplexF32}(undef,len)
    read!(fn, z)
end;

# Load the first data file
z = load_iq("scene3-640x480-60-350M-64M-40M.dat");

# -- First File Metadata --
# Centre Frequency
fc = 350e6
# Sampling Rate
fs = 64e6

# Pixel Clock Frequency
fp = 22.175e6



