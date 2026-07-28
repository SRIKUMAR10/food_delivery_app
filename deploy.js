const { spawn } = require('child_process');

const ls = spawn('npx.cmd', ['firebase-tools', 'deploy', '--only', 'firestore:rules'], {
  cwd: __dirname,
  stdio: 'pipe',
  shell: true
});

ls.stdout.on('data', (data) => {
  console.log(`stdout: ${data}`);
});

ls.stderr.on('data', (data) => {
  console.error(`stderr: ${data}`);
});

ls.on('close', (code) => {
  console.log(`child process exited with code ${code}`);
});
