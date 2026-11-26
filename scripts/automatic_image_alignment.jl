include(joinpath(@__DIR__, "..", "src", "HDMIEavesdropping.jl"))
using .HDMIEavesdropping, DSP, WAV, FFTW, Plots
include(joinpath(@__DIR__, "config.jl"))

# Load the first data file
z = load_iq(RECORDING_1);

# Take the first 30 million samples for pixel clock estimation
z_short = z[1:30_000_000]  

# Interpolate and resample to the pixel clock frequency
z_resampled = resample(z, fp / fs)

start = find_frame_start(z_resampled, xt, yt; n=10)

print(start)

# Convert the resampled data into an image
image = permutedims(reshape(abs.(z_resampled[start:start+xt*yt-1]), xt, yt))
# Plot
p = heatmap(image, color = :grays, yflip=true, title="Automatically Aligned Image")

display(p)