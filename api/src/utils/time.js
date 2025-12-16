// Time utilities

export function getNextBatchTime() {
  const now = new Date();
  const currentSeconds = now.getSeconds();
  const currentMilliseconds = now.getMilliseconds();

  let secondsUntilNext15;
  if (currentSeconds < 15) {
    // Next 15 seconds is in this minute
    secondsUntilNext15 = 15 - currentSeconds;
  } else {
    // Next 15 seconds is in next minute
    secondsUntilNext15 = 60 - currentSeconds + 15;
  }

  // Convert to milliseconds and subtract current milliseconds
  return secondsUntilNext15 * 1000 - currentMilliseconds;
}

export function formatUptime(seconds) {
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const secs = Math.floor(seconds % 60);

  if (hours > 0) {
    return `${hours}h ${minutes}m ${secs}s`;
  } else if (minutes > 0) {
    return `${minutes}m ${secs}s`;
  } else {
    return `${secs}s`;
  }
}
