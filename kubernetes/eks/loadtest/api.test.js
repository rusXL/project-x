import http from "k6/http";
import { check, sleep } from "k6";

export const options = {
  stages: [
    { duration: "30s", target: 10 },
    { duration: "1m", target: 50 },
    { duration: "1m", target: 100 },
    { duration: "1m", target: 200 },
    { duration: "1m", target: 500 },
    { duration: "2m", target: 1000 }, // load test target (slo should be respected here)
    // { duration: "1m", target: 2000 }, // stress test target (pods should not die here, slo can temporarily break)
    { duration: "30s", target: 0 },
  ],
  thresholds: {},
};

const BASE_URL = "http://api.agama.svc.cluster.local";

export default function () {
  // create
  const value = `load-${__VU}-${__ITER}-${Date.now()}`;
  const createRes = http.post(
    `${BASE_URL}/items`,
    JSON.stringify({ value }),
    {
      headers: { "Content-Type": "application/json" },
    },
  );
  check(createRes, { "create 201": (r) => r.status === 201 });

  const item = createRes.json();

  // list (once every 10 iterations, simulates page refresh)
  if (__ITER % 10 === 0) {
    const listRes = http.get(`${BASE_URL}/items`);
    check(listRes, { "list 200": (r) => r.status === 200 });
  }

  // toggle
  if (item && item.id) {
    const toggleRes = http.post(`${BASE_URL}/items/${item.id}/toggle`);
    check(toggleRes, { "toggle 200": (r) => r.status === 200 });

    // delete
    const deleteRes = http.del(`${BASE_URL}/items/${item.id}`);
    check(deleteRes, { "delete 204": (r) => r.status === 204 });
  }

  sleep(1);
}
