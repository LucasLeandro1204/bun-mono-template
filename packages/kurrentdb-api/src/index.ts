import { greet } from '@bun-mono-template/shared';

const port = Number(process.env.PORT ?? 3001);

Bun.serve({
  port,
  fetch(req) {
    const url = new URL(req.url);

    if (url.pathname === '/health') {
      return new Response(JSON.stringify({ ok: true }), { headers: { 'content-type': 'application/json' } });
    }

    if (url.pathname === '/orders' && req.method === 'POST') {
      return new Response(JSON.stringify({ id: crypto.randomUUID(), status: 'created' }), { headers: { 'content-type': 'application/json' } });
    }

    return new Response(greet('KurrentDB API'), { status: 200 });
  }
});

console.log(`KurrentDB API running on http://localhost:${port}`);
