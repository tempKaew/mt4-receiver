import { upsertQueue } from "../database.js";

export async function registerRoutes(fastify) {
  // MT4 data endpoint
  fastify.post(
    "/mt4",
    {
      schema: {
        body: { type: "object" },
      },
    },
    async (req, reply) => {
      try {
        // Validate required field
        if (!req.body.acc_number) {
          reply.code(400);
          return { success: false, error: "acc_number is required" };
        }

        const result = await upsertQueue(req.body);
        return {
          success: true,
          acc_number: result.acc_number,
          action: result.id ? "updated" : "inserted",
        };
      } catch (error) {
        reply.code(500);
        return { success: false, error: error.message };
      }
    }
  );

  // Health check endpoint
  fastify.get("/health", async (req, reply) => {
    return {
      status: "ok",
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
    };
  });

  // API info endpoint
  fastify.get("/", async (req, reply) => {
    return {
      name: "MT4 Receiver API",
      version: "1.0.0",
      endpoints: {
        "POST /mt4": "Receive MT4 data",
        "GET /health": "Health check",
        "GET /": "API information",
      },
    };
  });
}
