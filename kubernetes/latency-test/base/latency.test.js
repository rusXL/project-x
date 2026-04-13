import http from "k6/http";
import { check, sleep } from "k6";

const BASE_URL = __ENV.BASE_URL || "http://api.agama.svc.cluster.local";
const CLUSTER = __ENV.CLUSTER || "eks";

export const options = {
  tags: { cluster: CLUSTER },
  stages: [
    { duration: "30s", target: 50 },
    { duration: "10m", target: 50 },
    { duration: "30s", target: 0 },
  ],
  thresholds: {},
};

export default function () {
  const value = `latency-${CLUSTER}-${__VU}-${__ITER}-${Date.now()}`;
  const createRes = http.post(
    `${BASE_URL}/items`,
    JSON.stringify({ value }),
    {
      headers: { "Content-Type": "application/json" },
    },
  );
  check(createRes, { "create 201": (r) => r.status === 201 });

  const item = createRes.json();

  if (__ITER % 10 === 0) {
    const listRes = http.get(`${BASE_URL}/items`);
    check(listRes, { "list 200": (r) => r.status === 200 });
  }

  if (item && item.id) {
    const toggleRes = http.post(`${BASE_URL}/items/${item.id}/toggle`);
    check(toggleRes, { "toggle 200": (r) => r.status === 200 });

    const deleteRes = http.del(`${BASE_URL}/items/${item.id}`);
    check(deleteRes, { "delete 204": (r) => r.status === 204 });
  }

  sleep(1);
}
