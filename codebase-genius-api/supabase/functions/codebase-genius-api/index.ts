// supabase/functions/codebase-genius-api/index.ts
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

serve((req) => {
  return new Response("✅ Codebase Genius API is running!", { status: 200 });
});

