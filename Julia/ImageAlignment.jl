using DSP, WAV, FFTW, Plots

include("FileLoader.jl")
include("config.jl")

# Load the first data file
z = load_iq(RECORDING_1);

# Interpolate and resample to the pixel clock frequency
z_resampled = resample(z, fp / fs)

# Testing dividing an image into different frames
z_1 = z_resampled[1:xt*yt]
z_5 = z_resampled[4*xt*yt+1:5*xt*yt]
top_half_1_bottom_half_5 = vcat(z_1[1:xt*yt÷2], z_5[xt*yt÷2+1:end])
top_half_1_bottom_half_5_image = permutedims(reshape(abs.(top_half_1_bottom_half_5), xt, yt))

# Convert the resampled data into an image
image = permutedims(reshape(abs.(z_resampled[1:xt*yt]), xt, yt))

# Translate over so the blanking intervals are at the right and bottom
aligned = circshift(top_half_1_bottom_half_5_image, (195, 215))

# Plot
heatmap(aligned, color = :grays, yflip=true)
