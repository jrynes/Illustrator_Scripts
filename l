// 1) A custom middleware that directly sends index.html if requested:
function serveIndexDirectly(req, res, next) {
  if (req.url === '/' || req.url === '/index.html') {
    // BrowserSync will serve index.html from disk immediately:
    res.end(require('fs').readFileSync(
      require('path').join(__dirname, 'dist/pcui', 'index.html')
    ));
  } else {
    next();
  }
}