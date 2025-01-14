import { defineConfig } from "vite";
import { nodePolyfills } from "vite-plugin-node-polyfills";
import resolve from "vite-plugin-resolve";

const aztecVersion = "0.68.0";

export default defineConfig({
    plugins: [
        process.env.NODE_ENV === "production"
            ? /** @type {any} */ (
                resolve({
                    "@aztec/bb.js": `export * from "https://unpkg.com/@aztec/bb.js@${aztecVersion}/dest/browser/index.js"`,
                })
            )
            : undefined,
        nodePolyfills({ protocolImports: true }),
    ].filter(Boolean),
    resolve: {
        alias: {
            'fs/promises': 'node:fs/promises',
            'fs': 'node:fs',
            'path': 'node:path',
        },
    },
    build: {
        target: "esnext",
        sourcemap: true,
        minify: false,
        rollupOptions: {
            input: {
                main: 'index.html',
                transactions: 'public/transactions.html',
                apps: 'public/apps.html',
                tokens: 'public/tokens.html',
            },
        },
    },
    base: '/',
    optimizeDeps: {
        include: ['@aztec/bb.js'],
        esbuildOptions: {
            target: "esnext",
            sourcemap: true,
            minify: false,
        },
    },
    server: {
        watch: {
            ignored: ['**/node_modules/**', '**/.git/**'],
        },
    },
});
