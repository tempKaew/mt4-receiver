import Fastify from "fastify";
import { config } from "./src/config.js";
import { registerRoutes } from "./src/routes/routes.js";
import { startBatchWorker } from "./src/services/batch-worker.js";

// Create Fastify instance
const fastify = Fastify({
  logger: {
    level: "info",
    transport: {
      target: "pino-pretty",
      options: {
        colorize: true,
        translateTime: "HH:MM:ss Z",
        ignore: "pid,hostname",
      },
    },
  },
});

// Register routes
await registerRoutes(fastify);

// Start server
try {
  await fastify.listen({
    port: config.PORT,
    host: "0.0.0.0",
  });

  console.log(`🚀 Server listening on port ${config.PORT}`);
  console.log(`📍 API available at http://localhost:${config.PORT}/`);

  // Start batch worker
  startBatchWorker();
} catch (err) {
  console.error("❌ Error starting server:", err);
  process.exit(1);
}
