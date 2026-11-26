include(joinpath(@__DIR__, "..", "src", "HDMIEavesdropping.jl"))
using .HDMIEavesdropping, DSP, WAV, FFTW, Plots, Statistics
include(joinpath(@__DIR__, "config.jl"))

# Load the first data file
z = load_iq(RECORDING_1);

# Take the first 30 million samples for pixel clock estimation
z_short = z[1:30_000_000]  

# Interpolate and resample to the pixel clock frequency
z_resampled = resample(z, fp / fs)

start = find_frame_start(z_resampled, xt, yt; n=10)

avg0 = average_frames(z_resampled, xt, yt, 10; shift=(0, 0))
prof = vec(mean(avg0; dims=1))
plot(prof .- mean(prof); label="column mean")