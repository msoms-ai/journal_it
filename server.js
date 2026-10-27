const { createServer } = require('http');
const { parse } = require('url');
const fs = require('fs');
const path = require('path');
const next = require('next');

// Auto-detect whether production build exists
const hasBuild = fs.existsSync(path.join(__dirname, '.next', 'BUILD_ID'));
const dev = !hasBuild;

console.log(`> Initializing Next.js app (hasBuild=${hasBuild}, dev=${dev})...`);

const app = next({ dev, dir: __dirname });
const handle = app.getRequestHandler();

const port = process.env.PORT || 3000;

app.prepare()
  .then(() => {
    const server = createServer((req, res) => {
      const parsedUrl = parse(req.url, true);
      handle(req, res, parsedUrl);
    });

    server.listen(port, (err) => {
      if (err) {
        console.error('Server listen error:', err);
        throw err;
      }
      console.log(`> Ready on ${port} (mode: ${dev ? 'development' : 'production'})`);
    });
  })
  .catch((err) => {
    console.error('Fatal error during Next.js app.prepare():', err);
    // Serve informative page instead of dying with blank 500
    try {
      const fallbackServer = createServer((req, res) => {
        res.writeHead(500, { 'Content-Type': 'text/html; charset=utf-8' });
        res.end(`
          <!DOCTYPE html>
          <html>
            <head><title>صَحِّف | Application Setup</title></head>
            <body style="font-family: -apple-system, sans-serif; background: #fafafa; padding: 40px; text-align: center;">
              <div style="max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
                <h2 style="color: #8B0000;">صَحِّف — Initialization Notice</h2>
                <p>The Next.js production build has not been run yet.</p>
                <p style="background: #f1f1f1; padding: 12px; border-radius: 8px; font-family: monospace; color: #333; text-align: left; font-size: 13px;">
                  ${err.message}
                </p>
                <p><strong>Action required in Plesk:</strong></p>
                <p>1. In Node.js Dashboard, click <b>"Run script"</b> and select <b>"build"</b>.</p>
                <p>2. Then click <b>"Restart App"</b>.</p>
              </div>
            </body>
          </html>
        `);
      });
      fallbackServer.listen(port);
    } catch (e) {
      console.error('Could not start fallback server:', e);
    }
  });
