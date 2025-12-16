// Logging utilities

export function logInfo(message, data = {}) {
  console.log(`ℹ️  ${message}`, data);
}

export function logError(message, error = {}) {
  console.error(`❌ ${message}`, error);
}

export function logSuccess(message, data = {}) {
  console.log(`✅ ${message}`, data);
}

export function logWarning(message, data = {}) {
  console.warn(`⚠️  ${message}`, data);
}
