const { createProxyMiddleware } = require('http-proxy-middleware');
const history = require('connect-history-api-fallback');

// Pattern to exclude static file requests
const staticRequestPattern = /^(\/)?(index\.html|favicon\.ico|.*\.css|.*\.js|runtime\..*\.js|polyfills\..*\.js|main\..*\.js)$/;

// Specific Proxy Middleware
const specificProxy = createProxyMiddleware(['/filing', '/retrieval', '/pc-manage', '/idaas'], {
  target: (path) => {
    if (path.startsWith('/idaas')) {
      return 'https://idaas-services-fqt.etc.uspto.gov';
    }
    if (path.startsWith('/filing') || path.startsWith('/retrieval') || path.startsWith('/pc-manage')) {
      return 'https://pctr.fqt.uspto.gov';
    }
  },
  changeOrigin: true,
  secure: false,
  logLevel: 'debug',
  pathFilter: (path, req) => {
    if (req.url === '/' || req.url === '/index.html') {
      console.log(`[Specific Proxy] Excluding request: ${req.url}`);
      return false; // Exclude static requests
    }
    return true; // Proxy all other requests
  },
  pathRewrite: {
    '^/pc-manage': '/manage', // Rewrite /pc-manage to /manage
  },
});

// Dynamic .gov Proxy Middleware
const dynamicGovProxy = createProxyMiddleware({
  changeOrigin: true,
  secure: false,
  logLevel: 'debug',
  pathFilter: (path, req) => {
    // Exclude static file requests
    if (staticRequestPattern.test(req.url)) {
      console.log(`[Dynamic Proxy] Excluding static request: ${req.url}`);
      return false;
    }
    // Allow only .gov requests
    const isGovRequest = req.headers.host && req.headers.host.endsWith('.gov');
    console.log(`[Dynamic Proxy] Is .gov request? ${isGovRequest}`);
    return isGovRequest;
  },
  router: (pathname, req) => {
    if (!req.headers || !req.headers.host) {
      console.error('[Dynamic Proxy Router] Missing host header in request.');
      return null; // Gracefully handle missing headers
    }

    // Generate the target dynamically
    const targetUrl = `https://${req.headers.host}`;
    console.log(`[Dynamic Proxy Router] Routing ${pathname} to ${targetUrl}`);
    return targetUrl;
  },
});

// Static Middleware for History API Fallback
const staticMiddleware = history({
  disableDotRule: true, // Ensures proper handling of paths with dots
  verbose: true, // Logs rewrites
});

// Debugging Middleware
const logMiddleware = (name) => (req, res, next) => {
  console.log(`[${name}] Handling request: ${req.method} ${req.url}`);
  next();
};

// Lite Server Configuration
const LITE_SERVER_CONFIG = {
  files: 'dist/pcui/**/*.*', // Watch for file changes
  server: {
    baseDir: 'dist/pcui',
    index: 'index.html',
    middleware: [
      logMiddleware('Static Middleware'),
      staticMiddleware, // Serves static files
      logMiddleware('Specific Proxy'),
      specificProxy, // Handles specific routes
      logMiddleware('Dynamic Proxy'),
      dynamicGovProxy, // Handles .gov requests
    ],
  },
};

module.exports = LITE_SERVER_CONFIG;
