// Request validation middleware

export function validateMT4Data(req, reply, done) {
  const { acc_number } = req.body;

  if (!acc_number) {
    reply.code(400);
    return reply.send({
      success: false,
      error: "acc_number is required",
    });
  }

  if (typeof acc_number !== "number") {
    reply.code(400);
    return reply.send({
      success: false,
      error: "acc_number must be a number",
    });
  }

  done();
}

export function validateHealthCheck(req, reply, done) {
  // Add any health check validation here
  done();
}
