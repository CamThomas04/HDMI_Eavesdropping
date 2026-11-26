# src/HDMIEavesdropping.jl
module HDMIEavesdropping

using DSP, FFTW, Statistics

include("file_loader.jl")
include("pixel_clock.jl")
include("frame_alignment.jl")

export load_iq, estimate_pixel_clock_frequency, average_frames, find_frame_start

end