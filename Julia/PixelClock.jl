using DSP, Statistics, Polynomials

function estimate_pixel_clock_frequency(z, fs, xt, yt; nframes = 4, nominal_rate = 60)
    # Truncate to about 4 frames of samples
    N = nframes * round(Int, fs / nominal_rate)

    # Compute Magnitude of the truncated signal
    z_truncated = abs.(z[1:N])

    # Subtract the mean to center the signal around zero
    z_truncated .-= mean(z_truncated)

    # Compute Auto-Correlation of the truncated signal
    R = xcorr(z_truncated)[N:end]

    # Search around 59-61 Hz window
    lo, hi = round(Int, fs / 61), round(Int, fs / 59)
    lags = lo:hi

    # Find the integer lag of the peak in samples
    peak_lag = lo + argmax(R[lo+1:hi+1]) - 1

    # Pick some neighbours of the peak
    y1, y2, y3 = R[peak_lag-1], R[peak_lag], R[peak_lag+1]

    # Fit a parabola to the peak and its neighbours
    p = fit(Polynomial, [-1, 0, 1], [y1, y2, y3])

    # Take where the derivative of the parabola is zero to find the fine peak location
    peak_fine = peak_lag + roots(derivative(p))[1]

    frame_rate = fs / peak_fine
    fp_estimated = frame_rate * xt * yt

    return frame_rate, fp_estimated
end