import type { APIRoute } from "astro";
import { llmsFullTxt } from "../lib/llms.ts";

export const GET: APIRoute = () => new Response(llmsFullTxt(), { headers: { "content-type": "text/plain; charset=utf-8" } });
