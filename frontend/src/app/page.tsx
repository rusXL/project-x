import ItemList from "./items";
import { getItems } from "./actions";

// This runs entirely on the server
export default async function HomePage() {
  let items = [];
  let loadError = null;

  try {
    items = await getItems();
  } catch {
    loadError = "Could not reach the API.";
  }

  return (
    <main className="min-h-screen bg-background flex items-start justify-center py-10 px-4">
      <div className="w-full max-w-sm space-y-6">
        {/* Header */}
        <div className="text-center space-y-1">
          <div className="text-5xl">🦎</div>
          <h1 className="text-2xl font-semibold tracking-tight">AGAMA</h1>
          <p className="text-sm text-muted-foreground">
            A Generic App to Manage Anything
          </p>
        </div>

        <ItemList initialItems={items} loadError={loadError} />
      </div>
    </main>
  );
}
