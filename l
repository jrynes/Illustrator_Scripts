const { createProxyMiddleware } = require('http-proxy-middleware');
const history = require('connect-history-api-fallback');

// Pattern for excluding static files
const staticRequestPattern = /^(\/)?(index\.html|favicon\.ico|.*\.css|.*\.js|runtime\..*\.js|polyfills\..*\.js|main\..*\.js)$/;

// Specific Proxy Middleware
const specificProxy = createProxyMiddleware(['/filing', '/retrieval', '/pc-manage', '/idaas'], {
  target: 'https://default-target.com', // Required default target
  changeOrigin: true,
  secure: false,
  logLevel: 'debug',
  pathFilter: (path, req) => {
    if (req.url === '/' || req.url === '/index.html') {
      console.log(`[Specific Proxy] Excluding request: ${req.url}`);
      return false; // Exclude static requests
    }
    return true;
  },
  router: (req) => {
    if (req.url.startsWith('/idaas')) {
      return 'https://idaas-services-fqt.etc.uspto.gov';
    }
    if (req.url.startsWith('/filing') || req.url.startsWith('/retrieval') || req.url.startsWith('/pc-manage')) {
      return 'https://pctr.fqt.uspto.gov';
    }
    return 'https://default-target.com'; // Fallback
  },
  pathRewrite: {
    '^/pc-manage': '/manage',
  },
});

// Dynamic Proxy Middleware
const dynamicGovProxy = createProxyMiddleware({
  target: 'https://default-gov-target.com', // Required default target
  changeOrigin: true,
  secure: false,
  logLevel: 'debug',
  pathFilter: (path, req) => {
    if (staticRequestPattern.test(req.url)) {
      console.log(`[Dynamic Proxy] Excluding static request: ${req.url}`);
      return false;
    }

    const isGovRequest = req.headers.host && req.headers.host.endsWith('.gov');
    console.log(`[Dynamic Proxy] Is .gov request? ${isGovRequest}`);
    return isGovRequest;
  },
  router: (pathname, req) => {
    if (!req.headers || !req.headers.host) {
      console.error('[Dynamic Proxy Router] Missing host header in request.');
      return 'https://fallback-gov-target.com';
    }
    const targetUrl = `https://${req.headers.host}`;
    console.log(`[Dynamic Proxy Router] Routing ${pathname} to ${targetUrl}`);
    return targetUrl;
  },
});

// Static Middleware
const staticMiddleware = history({
  disableDotRule: true,
  verbose: true,
});

// Debug Middleware
const logMiddleware = (name) => (req, res, next) => {
  console.log(`[${name}] Handling request: ${req.method} ${req.url}`);
  next();
};

// Lite Server Configuration
const LITE_SERVER_CONFIG = {
  files: 'dist/pcui/**/*.*',
  server: {
    baseDir: 'dist/pcui',
    index: 'index.html',
    middleware: [
      logMiddleware('Static Middleware'),
      staticMiddleware,
      logMiddleware('Specific Proxy'),
      specificProxy,
      logMiddleware('Dynamic Proxy'),
      dynamicGovProxy,
    ],
  },
};

module.exports = LITE_SERVER_CONFIG;
