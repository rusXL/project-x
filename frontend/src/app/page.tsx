"use client";

import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Separator } from "@/components/ui/separator";
import { cn } from "@/lib/utils";
import { Trash2, WifiOff, Loader2 } from "lucide-react";

type Item = {
  id: number;
  value: string;
  state: 0 | 1;
};

const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8000";

export default function HomePage() {
  const [items, setItems] = useState<Item[]>([]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [actionError, setActionError] = useState<string | null>(null);

  useEffect(() => {
    fetch(`${API_BASE_URL}/items`)
      .then((r) => r.json())
      .then(setItems)
      .catch(() => setLoadError("Could not reach the API."))
      .finally(() => setLoading(false));
  }, []);

  const add = async () => {
    const value = input.trim();
    if (!value || submitting) return;
    setSubmitting(true);
    setActionError(null);
    try {
      const res = await fetch(`${API_BASE_URL}/items`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ value }),
      });
      if (!res.ok) {
        const body = await res.json().catch(() => null);
        throw new Error(typeof body?.detail === "string" ? body.detail : "Could not add item.");
      }
      const item: Item = await res.json();
      setItems((prev) => [...prev, item]);
      setInput("");
    } catch (e) {
      setActionError("Something went wrong.");
    } finally {
      setSubmitting(false);
    }
  };

  const toggle = async (id: number) => {
    setActionError(null);
    try {
      const res = await fetch(`${API_BASE_URL}/items/${id}/toggle`, { method: "POST" });
      if (!res.ok) throw new Error("Could not update item.");
      const updated: Item = await res.json();
      setItems((prev) => prev.map((i) => (i.id === updated.id ? updated : i)));
    } catch (e) {
      setActionError("Something went wrong.");
    }
  };

  const remove = async (id: number) => {
    setActionError(null);
    try {
      const res = await fetch(`${API_BASE_URL}/items/${id}`, { method: "DELETE" });
      if (!res.ok && res.status !== 204) throw new Error("Could not delete item.");
      setItems((prev) => prev.filter((i) => i.id !== id));
    } catch (e) {
      setActionError("Something went wrong.");
    }
  };

  const sorted = [...items].sort((a, b) =>
    a.state !== b.state ? a.state - b.state : a.id - b.id
  );

  return (
    <main className="min-h-screen bg-background flex items-start justify-center py-10 px-4">
      <div className="w-full max-w-sm space-y-6">

        {/* Header */}
        <div className="text-center space-y-1">
          <div className="text-5xl">🦎</div>
          <h1 className="text-2xl font-semibold tracking-tight">AGAMA</h1>
          <p className="text-sm text-muted-foreground">A Generic App to Manage Anything</p>
        </div>

        {/* Add item */}
        <form
          onSubmit={(e) => { e.preventDefault(); void add(); }}
          className="flex gap-2"
        >
          <Input
            placeholder="Add an item..."
            value={input}
            onChange={(e) => setInput(e.target.value)}
            disabled={submitting || !!loadError}
            autoComplete="off"
            autoFocus
          />
          <Button type="submit" disabled={submitting || !input.trim() || !!loadError}>
            {submitting ? <Loader2 className="h-4 w-4 animate-spin" /> : "Add"}
          </Button>
        </form>

        {/* Action error — inline under form */}
        {actionError && (
          <p className="text-xs text-destructive -mt-3">{actionError}</p>
        )}

        {/* List */}
        <div className="space-y-1">

          {/* Loading spinner */}
          {loading && (
            <div className="flex items-center justify-center py-10 text-muted-foreground">
              <Loader2 className="h-5 w-5 animate-spin" />
            </div>
          )}

          {/* Load error — centered with icon, replaces list */}
          {!loading && loadError && (
            <div className="flex flex-col items-center gap-2 py-10 text-muted-foreground">
              <WifiOff className="h-8 w-8" />
              <p className="text-sm">{loadError}</p>
            </div>
          )}

          {/* Empty state */}
          {!loading && !loadError && sorted.length === 0 && (
            <p className="text-sm text-muted-foreground text-center py-6">
              No items yet. Add one above.
            </p>
          )}

          {!loading && !loadError && sorted.map((item) => (
            <div
              key={item.id}
              className={cn(
                "group flex cursor-pointer items-center justify-between rounded-md px-3 py-2 text-sm transition-colors",
                item.state === 1
                  ? "bg-muted text-muted-foreground hover:bg-muted/80"
                  : "hover:bg-muted/60"
              )}
              onClick={() => void toggle(item.id)}
            >
              <span
                className={cn(
                  "flex-1 text-left break-all",
                  item.state === 1 && "line-through"
                )}
              >
                {item.value}
              </span>
              <Button
                type="button"
                variant="ghost"
                size="icon"
                className="h-6 w-6 opacity-0 group-hover:opacity-100 text-muted-foreground hover:text-destructive"
                onClick={(e) => {
                  e.stopPropagation();
                  void remove(item.id);
                }}
                aria-label="Delete"
              >
                <Trash2 className="h-3.5 w-3.5" />
              </Button>
            </div>
          ))}
        </div>
      </div>
    </main>
  );
}