import { greet } from '@bun-mono-template/shared';
import { z } from 'zod';

const port = Number(process.env.PORT ?? 3001);

const CreateOrderSchema = z.object({
  customerId: z.string().min(1),
  amount: z.number().positive(),
  currency: z.string().length(3)
});

Bun.serve({
  port,
  async fetch(req) {
    const url = new URL(req.url);

    if (url.pathname === '/health') {
      return new Response(JSON.stringify({ ok: true }), { headers: { 'content-type': 'application/json' } });
    }

    if (url.pathname === '/orders' && req.method === 'POST') {
      let body: unknown;

      try {
        body = await req.json();
      } catch {
        return new Response(JSON.stringify({ error: 'Invalid JSON body' }), {
          status: 400,
          headers: { 'content-type': 'application/json' }
        });
      }

      const result = CreateOrderSchema.safeParse(body);

      if (!result.success) {
        return new Response(JSON.stringify({
          error: 'Validation failed',
          issues: result.error.issues
        }), {
          status: 422,
          headers: { 'content-type': 'application/json' }
        });
      }

      const order = {
        id: crypto.randomUUID(),
        status: 'created',
        ...result.data
      };

      return new Response(JSON.stringify(order), {
        status: 201,
        headers: { 'content-type': 'application/json' }
      });
    }

    return new Response(greet('KurrentDB API'), { status: 200 });
  }
});

console.log(`KurrentDB API running on http://localhost:${port}`);
