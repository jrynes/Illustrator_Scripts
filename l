const { createProxyMiddleware } = require('http-proxy-middleware');

module.exports = {
  // Start BrowserSync on port 3000 (for example)
  port: 3000,
  // Serve from the `dist` folder
  server: {
    baseDir: './dist',
    // The key: define a middleware array
    middleware: [
      // 1) Middleware for skipping static files (not proxied)
      function skipStaticFiles(req, res, next) {
        // If the request URL starts with /static or /assets or something
        // that you store as static, we just call next() so BrowserSync
        // serves it from `baseDir` directly.
        if (req.url.startsWith('/static/') || req.url.startsWith('/assets/')) {
          return next(); // Serve from ./dist
        }
        next();
      },

      // 2) Proxy if the URL ends with one of /foo, /bar, /baz
      createProxyMiddleware(['/foo', '/bar', '/baz'], {
        target: 'http://localhost:4000',
        changeOrigin: true,
        logLevel: 'debug',

        // The bypass option can be used to skip proxy if it doesn't actually match
        bypass: (req, res, opts) => {
          // If the path truly ends with /foo or /bar or /baz, we do nothing => proxy it
          if (
            req.url.endsWith('/foo') ||
            req.url.endsWith('/bar') ||
            req.url.endsWith('/baz')
          ) {
            // Use this proxy
          } else {
            // Return req.url to skip proxying, let next middleware handle
            return req.url;
          }
        },
      }),

      // 3) Proxy if the hostname ends with .gov
      //    We'll write a small custom middleware that uses createProxyMiddleware on the fly
      function proxyGovDomains(req, res, next) {
        // Check if the "Host" header ends with .gov
        // (BrowserSync sets req.headers.host to e.g. "localhost:3000" in dev;
        //  but if you truly have a .gov domain in production, this can detect it.)
        const host = req.headers.host || '';

        if (host.endsWith('.gov')) {
          // Dynamically apply a proxy
          const proxy = createProxyMiddleware({
            target: 'http://some-gov-backend:3000',
            changeOrigin: true,
            logLevel: 'debug',
          });
          // Call that proxy middleware
          return proxy(req, res, next);
        }

        // Otherwise, skip
        next();
      },

      // 4) (Optional) A final catch-all proxy or other middleware
      //    If you want everything else not matched above to be proxied,
      //    you could add one more createProxyMiddleware on "/".
      // createProxyMiddleware('/', {
      //   target: 'http://localhost:8080',
      //   changeOrigin: true,
      //   logLevel: 'debug'
      // })
    ],
  },
};
