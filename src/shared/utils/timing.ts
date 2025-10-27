/**
 * Timing Utilities
 * Precise timing for data collection
 */

/**
 * Get high-precision timestamp in milliseconds
 * Uses Performance API for better accuracy
 */
export const getHighPrecisionTimestamp = (): number => {
  return performance.now();
};

/**
 * Calculate reaction time between two timestamps
 */
export const calculateReactionTime = (startTime: number, endTime: number): number => {
  return Math.round(endTime - startTime);
};

/**
 * Format milliseconds to readable time string
 */
export const formatTime = (ms: number): string => {
  if (ms < 1000) {
    return `${Math.round(ms)}ms`;
  }
  
  const seconds = Math.floor(ms / 1000);
  const remainingMs = Math.round(ms % 1000);
  
  if (seconds < 60) {
    return `${seconds}.${remainingMs}s`;
  }
  
  const minutes = Math.floor(seconds / 60);
  const remainingSeconds = seconds % 60;
  
  return `${minutes}m ${remainingSeconds}s`;
};

/**
 * Format milliseconds to MM:SS format
 */
export const formatTimeMMSS = (ms: number): string => {
  const totalSeconds = Math.floor(ms / 1000);
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  
  return `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
};

/**
 * Wait for specified milliseconds
 */
export const wait = (ms: number): Promise<void> => {
  return new Promise((resolve) => setTimeout(resolve, ms));
};

/**
 * Create a timer with callback
 */
export class Timer {
  private startTime: number = 0;
  private endTime: number = 0;
  private isRunning: boolean = false;

  start(): void {
    this.startTime = performance.now();
    this.isRunning = true;
    this.endTime = 0;
  }

  stop(): number {
    if (!this.isRunning) {
      return 0;
    }
    
    this.endTime = performance.now();
    this.isRunning = false;
    return this.elapsed();
  }

  elapsed(): number {
    if (this.isRunning) {
      return performance.now() - this.startTime;
    }
    return this.endTime - this.startTime;
  }

  reset(): void {
    this.startTime = 0;
    this.endTime = 0;
    this.isRunning = false;
  }
}

/**
 * Debounce function
 */
export const debounce = <T extends (...args: any[]) => any>(
  func: T,
  delay: number
): ((...args: Parameters<T>) => void) => {
  let timeoutId: NodeJS.Timeout;

  return (...args: Parameters<T>) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => {
      func(...args);
    }, delay);
  };
};

/**
 * Throttle function
 */
export const throttle = <T extends (...args: any[]) => any>(
  func: T,
  limit: number
): ((...args: Parameters<T>) => void) => {
  let inThrottle: boolean;

  return (...args: Parameters<T>) => {
    if (!inThrottle) {
      func(...args);
      inThrottle = true;
      setTimeout(() => (inThrottle = false), limit);
    }
  };
};



