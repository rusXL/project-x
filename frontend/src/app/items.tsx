"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { cn } from "@/lib/utils";
import { Trash2, WifiOff, Loader2 } from "lucide-react";
import { addItem, toggleItem, deleteItem } from "./actions";

type Item = {
  id: number;
  value: string;
  state: 0 | 1;
};

export default function ItemList({
  initialItems,
  loadError,
}: {
  initialItems: Item[];
  loadError: string | null;
}) {
  const [items, setItems] = useState<Item[]>(initialItems);
  const [input, setInput] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [actionError, setActionError] = useState<string | null>(null);

  const add = async () => {
    const value = input.trim();
    if (!value || submitting) return;
    setSubmitting(true);
    setActionError(null);
    try {
      const item = await addItem(value);
      setItems((prev) => [...prev, item]);
      setInput("");
    } catch {
      setActionError("Something went wrong.");
    } finally {
      setSubmitting(false);
    }
  };

  const toggle = async (id: number) => {
    setActionError(null);
    try {
      const updated = await toggleItem(id);
      setItems((prev) => prev.map((i) => (i.id === updated.id ? updated : i)));
    } catch {
      setActionError("Something went wrong.");
    }
  };

  const remove = async (id: number) => {
    setActionError(null);
    try {
      await deleteItem(id);
      setItems((prev) => prev.filter((i) => i.id !== id));
    } catch {
      setActionError("Something went wrong.");
    }
  };

  const sorted = [...items].sort((a, b) =>
    a.state !== b.state ? a.state - b.state : a.id - b.id,
  );

  return (
    <>
      {/* Add item */}
      <form
        onSubmit={(e) => {
          e.preventDefault();
          void add();
        }}
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
        <Button
          type="submit"
          disabled={submitting || !input.trim() || !!loadError}
        >
          {submitting ? <Loader2 className="h-4 w-4 animate-spin" /> : "Add"}
        </Button>
      </form>

      {/* Action error — inline under form */}
      {actionError && (
        <p className="text-xs text-destructive -mt-3">{actionError}</p>
      )}

      {/* List */}
      <div className="space-y-1">
        {/* Load error */}
        {loadError && (
          <div className="flex flex-col items-center gap-2 py-10 text-muted-foreground">
            <WifiOff className="h-8 w-8" />
            <p className="text-sm">{loadError}</p>
          </div>
        )}

        {/* Empty state */}
        {!loadError && sorted.length === 0 && (
          <p className="text-sm text-muted-foreground text-center py-6">
            No items yet. Add one above.
          </p>
        )}

        {!loadError &&
          sorted.map((item) => (
            <div
              key={item.id}
              className={cn(
                "group flex cursor-pointer items-center justify-between rounded-md px-3 py-2 text-sm transition-colors",
                item.state === 1
                  ? "bg-muted text-muted-foreground hover:bg-muted/80"
                  : "hover:bg-muted/60",
              )}
              onClick={() => void toggle(item.id)}
            >
              <span
                className={cn(
                  "flex-1 text-left break-all",
                  item.state === 1 && "line-through",
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
    </>
  );
}
