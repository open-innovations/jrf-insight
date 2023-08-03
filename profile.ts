console.log('Beginning startup delay...');
await new Promise((resolve) => {
  setTimeout(() => {
    console.log('Startup delay completed...');
    resolve('Done');
  }, 10000);
});

await import('lume/cli.ts');

console.log('Finished build...');

console.log('Beginning closedown delay...');
await new Promise((resolve) => {
  setTimeout(() => {
    console.log('Closedown delay completed...');
    resolve('Done');
  }, 10000);
});

