/**************************************************
 * bs-config.js (Corrected)
 **************************************************/
const fs = require('fs');
const path = require('path');
const { createProxyMiddleware } = require('http-proxy-middleware');
const history = require('connect-history-api-fallback');

// If you actually need a logout map:
const logoutMap = require('./logout-map');

// Optional: If you have a special onProxyReq function:
function onProxyReq(proxyReq, req, res) {
  // Add custom headers or do logging here if needed
  // e.g.: proxyReq.setHeader('X-Special-Proxy-Header', 'foobar');
}

// Example: array of extensions to detect static resources
const staticFileExtensions = [
  '.ico',
  '.css',
  '.js',
  '.png',
  '.jpg',
  '.jpeg',
  '.gif',
  '.svg',
];

// Example: Main API proxy pointing to localhost:3000
const apiProxy = createProxyMiddleware({
  target: 'http://localhost:3000',
  onProxyReq,
  // ...any additional options
});

/**
 * Specific Proxy: for pctr.fqt.uspto.gov
 *   - pathFilter includes /filing, /retrieval, /pc-manage, etc.
 */
const specificProxy = createProxyMiddleware({
  target: 'https://pctr.fqt.uspto.gov',
  changeOrigin: true,
  secure: false,
  logger: console,

  // Use 'bypass' to skip proxy for certain conditions
  bypass: (req, res) => {
    const { pathname } = new URL(req.url, 'http://dummy'); // avoid Node <17 bug
    // If you want to fully skip proxy for certain paths:
    // e.g. if (pathname.match(/^\/something/)) return '/some/local/file.html';
    return null; // returning null = do not bypass
  },

  // Only proxy these specific paths
  pathFilter: (pathname, req) => {
    console.log(`[Specific Proxy] pathname: ${pathname}`);
    console.log(`[Specific Proxy] url: ${req.url}`);

    // Exclude direct index requests
    if (req.url === '/' || req.url === '/index.html') {
      console.log(`[Specific Proxy] Excluding request: ${req.url}`);
      return false; 
    }

    // Proxy these routes:
    if (
      pathname.match(/^\/filing/) ||
      pathname.match(/^\/retrieval/) ||
      pathname.match(/^\/pc-manage/)
    ) {
      return true;
    }
    return false;
  },

  pathRewrite: {
    '^/pc-manage': '/manage', // example rewrite
  },
});

/**
 * Specific Proxy - IDAAS
 */
const specificProxyIdaas = createProxyMiddleware({
  target: 'https://idaas-services-fqt.etc.uspto.gov',
  changeOrigin: true,
  secure: false,
  logger: console,

  // If you want to let certain paths bypass the proxy:
  bypass: (req, res) => {
    const { pathname } = new URL(req.url, 'http://dummy');
    // Example: if we only want to proxy /idaas*:
    if (!pathname.match(/^\/idaas/)) {
      return req.url; // returning original URL means "do not proxy"
    }
    return null;
  },

  pathFilter: (pathname, req) => {
    if (req.url === '/' || req.url === '/index.html') {
      console.log(`[Specific Proxy - Idaas] Excluding request: ${req.url}`);
      return false; // Exclude direct index requests
    }
    // Proxy only /idaas routes
    if (pathname.match(/^\/idaas/)) {
      return true;
    }
    return false;
  },
});

/**
 * Static Middleware for History API Fallback
 * This will rewrite all non-static requests to /index.html
 * so Angular routing works.
 */
const staticMiddleware = history({
  disableDotRule: true,
  verbose: true,
  rewrites: [
    // Serve known static file extensions directly:
    {
      from: /\/.*\.(js|css|ico|png|jpg|jpeg|gif|svg|ttf)$/,
      to: (context) => context.parsedUrl.pathname,
    },
    // For everything else, serve index.html
    {
      from: /\/.*/,
      to: '/index.html',
    },
  ],
});

/**
 * Debugging Middleware: logs each request
 */
function logMiddleware(name) {
  return (req, res, next) => {
    console.log(`[${name}] Handling: ${req.method} ${req.url}`);
    next();
  };
}

/**
 * Custom middleware that directly sends index.html if requested at `/` or `/index.html`.
 * This can short-circuit the rest of the middleware chain if desired.
 */
function serveIndexDirectly(req, res, next) {
  if (req.url === '/' || req.url === '/index.html') {
    const indexFile = path.join(__dirname, 'dist/pcui', 'index.html');
    if (fs.existsSync(indexFile)) {
      const content = fs.readFileSync(indexFile);
      res.end(content);
    } else {
      console.error(`Could not find ${indexFile}!`);
      res.statusCode = 404;
      res.end('404: index.html not found');
    }
  } else {
    next();
  }
}

/**
 * Logout Proxy (example)
 *   - Uses logoutMap to route to different targets
 */
const logoutProxy = createProxyMiddleware({
  // Provide a default target (it’ll get overridden in `router`):
  target: 'http://localhost:3000',
  changeOrigin: true,
  secure: false,
  logger: console,

  router: (req) => {
    // Expecting e.g. /logout/someSlug
    const match = req.url.match(/^\/logout([^/]+)/);
    if (!match) {
      // If no slug, fallback to default
      return 'http://localhost:3000';
    }
    const slug = match[1];
    const found = logoutMap.find((item) => item.slug === slug);

    // Return the matching URL or fallback
    return found ? found.url : 'http://localhost:3000';
  },

  pathFilter: (pathname, req) => {
    if (req.url === '/' || req.url === '/index.html') {
      console.log(`[Logout Proxy] Excluding request: ${req.url}`);
      return false; // exclude direct index
    }
    return true;
  },
});

/**
 * BrowserSync / Lite-Server Configuration
 */
const LITE_SERVER_CONFIG = {
  files: ['dist/pcui/**/*.*'], // watch for file changes
  server: {
    baseDir: 'dist/pcui',
    index: 'index.html',
    middleware: {
      // The numeric keys define order
      10: serveIndexDirectly,      // (1) Serve index directly if at root
      12: staticMiddleware,        // (2) History fallback for Angular routes
      13: logMiddleware('Proxy'),  // (3) Log requests
      14: specificProxy,           // (4) Proxy to pctr.fqt.uspto.gov
      15: specificProxyIdaas,      // (5) Proxy to IDAAS
      16: logMiddleware('API'),    // (6) Another logger
      17: apiProxy,                // (7) Example local API proxy
      18: logoutProxy,             // (8) Logout proxy
    },
  },
};

module.exports = LITE_SERVER_CONFIG;
