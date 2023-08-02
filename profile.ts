await new Promise((resolve) => {
  setTimeout(() => {
    console.log('Starting');
    resolve('Done');
  }, 10000);
});

await import('lume/cli.ts');

console.log('Finish!');