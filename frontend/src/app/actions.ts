"use server";

function getApiUrl() {
  const API_URL = process.env.API_URL;
  if (!API_URL) throw new Error("API_URL not set");
  return API_URL;
}

export async function getItems() {
  const url = getApiUrl();
  const res = await fetch(`${url}/items`, {
    cache: "no-store",
    next: { revalidate: 0 },
  });
  if (!res.ok) throw new Error("Could not reach the API.");
  return res.json();
}

export async function addItem(value: string) {
  const url = getApiUrl();
  const res = await fetch(`${url}/items`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ value }),
  });

  if (!res.ok) {
    const body = await res.json().catch(() => null);
    throw new Error(
      typeof body?.detail === "string" ? body.detail : "Could not add item.",
    );
  }

  return res.json();
}

export async function toggleItem(id: number) {
  const url = getApiUrl();
  const res = await fetch(`${url}/items/${id}/toggle`, { method: "POST" });
  if (!res.ok) throw new Error("Could not update item.");

  return res.json();
}

export async function deleteItem(id: number) {
  const url = getApiUrl();
  const res = await fetch(`${url}/items/${id}`, { method: "DELETE" });
  if (!res.ok && res.status !== 204) throw new Error("Could not delete item.");
}
