import fetch from "node-fetch";
import { getPending, markSent } from "../database.js";
import { config } from "../config.js";
import { getNextBatchTime } from "../utils/time.js";
import { logInfo, logError, logSuccess, logWarning } from "../utils/logger.js";
import { logBatchSummary } from "../utils/data-formatter.js";

export async function runBatch() {
  if (!config.SUPABASE_URL || !config.SUPABASE_TOKEN) {
    logWarning("Supabase URL or token not configured, skipping batch");
    return;
  }

  try {
    const rows = await getPending(50);
    if (rows.length === 0) {
      logInfo("No pending data to send");
      return;
    }

    const payload = rows.map((r) => JSON.parse(r.payload));

    const summary = logBatchSummary(payload);
    logInfo("Batch summary:", summary);

    const res = await fetch(config.SUPABASE_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${config.SUPABASE_TOKEN}`,
      },
      body: JSON.stringify(payload),
    });

    const responseText = await res.text();

    if (res.ok) {
      try {
        const result = JSON.parse(responseText);
        const ids = rows.map((r) => r.id);
        await markSent(ids);

        logSuccess(`Batch completed`, {
          sent_records: ids.length,
          success_count: result.success_count || ids.length,
          error_count: result.error_count || 0,
        });

        if (result.errors && result.errors.length > 0) {
          logWarning("Some records had errors", result.errors);
        }
      } catch (parseError) {
        // If response is not JSON, still mark as sent if status is ok
        const ids = rows.map((r) => r.id);
        await markSent(ids);
        logSuccess(`Sent ${ids.length} rows to Supabase`);
      }
    } else {
      let errorDetails;
      try {
        errorDetails = JSON.parse(responseText);
      } catch {
        errorDetails = responseText;
      }

      logError("Supabase request failed", {
        status: res.status,
        response: errorDetails,
      });
    }
  } catch (err) {
    logError("Batch worker error", { message: err.message });
  }
}

export function startBatchWorker() {
  logInfo("Batch worker started, sending data at 15 seconds of every minute");

  function scheduleNextRun() {
    const millisecondsUntilNext = getNextBatchTime();

    logInfo(
      `Next batch run in ${Math.round(millisecondsUntilNext / 1000)} seconds`
    );

    setTimeout(() => {
      runBatch();
      // Schedule the next run (every 60 seconds after the first one)
      setInterval(runBatch, 60000);
    }, millisecondsUntilNext);
  }

  scheduleNextRun();
}
