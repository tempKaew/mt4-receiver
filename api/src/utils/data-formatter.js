// Data formatting utilities

export function formatBatchPayload(rows) {
  const payload = rows.map((r) => JSON.parse(r.payload));

  return {
    data: payload,
    summary: {
      total_records: payload.length,
      accounts: [...new Set(payload.map((p) => p.acc_number))],
      date_range: {
        earliest: payload.reduce(
          (min, p) => (p.date < min ? p.date : min),
          payload[0]?.date
        ),
        latest: payload.reduce(
          (max, p) => (p.date > max ? p.date : max),
          payload[0]?.date
        ),
      },
      total_balance: payload.reduce((sum, p) => sum + (p.balance || 0), 0),
      total_equity: payload.reduce((sum, p) => sum + (p.equity || 0), 0),
    },
  };
}

export function logBatchSummary(payload) {
  const accounts = [...new Set(payload.map((p) => p.acc_number))];
  const totalBalance = payload.reduce((sum, p) => sum + (p.balance || 0), 0);
  const totalEquity = payload.reduce((sum, p) => sum + (p.equity || 0), 0);

  return {
    records: payload.length,
    accounts: accounts.length,
    account_numbers: accounts,
    total_balance: totalBalance.toFixed(2),
    total_equity: totalEquity.toFixed(2),
    sample_record: payload[0],
  };
}
