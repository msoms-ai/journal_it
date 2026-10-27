var spawnSync = require('child_process').spawnSync;
var fs = require('fs');
var path = require('path');

// Extract major version using plain ES5
var majorVersion = parseInt(process.versions.node.split('.')[0], 10);
console.log('[Build] Executing with Node.js version: ' + process.version);

var nextBin = path.join(__dirname, 'node_modules', 'next', 'dist', 'bin', 'next');

if (majorVersion < 18) {
  console.log('[Build] Detected legacy Node.js (' + process.version + '). Searching for modern Node in Plesk...');
  
  var candidates = [
    '/opt/plesk/node/20/bin/node',
    '/opt/plesk/node/22/bin/node',
    '/opt/plesk/node/18/bin/node'
  ];
  
  var modernNode = null;
  for (var i = 0; i < candidates.length; i++) {
    if (fs.existsSync(candidates[i])) {
      modernNode = candidates[i];
      break;
    }
  }

  if (modernNode) {
    var modernBinDir = path.dirname(modernNode);
    console.log('[Build] Found modern Node at: ' + modernNode);
    console.log('[Build] Relaunching build with modern Node and updated PATH...');
    
    var newEnv = {};
    for (var key in process.env) {
      if (process.env.hasOwnProperty(key)) {
        newEnv[key] = process.env[key];
      }
    }
    newEnv['PATH'] = modernBinDir + ':' + (process.env.PATH || '');
    newEnv['NODE_ENV'] = 'production';

    var res = spawnSync(modernNode, [nextBin, 'build'], {
      stdio: 'inherit',
      env: newEnv
    });

    process.exit(res.status || 0);
  } else {
    console.warn('[Build] No modern node found in /opt/plesk/node/. Proceeding with current runtime...');
  }
}

// If already running on modern node (Node 18+)
var runResult = spawnSync(process.execPath, [nextBin, 'build'], {
  stdio: 'inherit'
});

process.exit(runResult.status || 0);
