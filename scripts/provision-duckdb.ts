import { read } from "https://deno.land/x/streaming_zip/read.ts";
import { Buffer } from "https://deno.land/std@0.195.0/streams/buffer.ts";

const { os } = Deno.build;

const targetDirectory = new URL(import.meta.resolve('../lib')).pathname;

async function extractFilesFromZip(url: string, files: string[]) {
  // Reading a zip from a fetch response body:
  const req = await fetch(url);
  const stream = req.body!;

  for await (const entry of read(stream)) {
    if (entry.type === "file") {
      if (files.includes(entry.name)) {
        const buffer = new Buffer();
        await entry.body.stream().pipeTo(buffer.writable);
        await Deno.writeFile(`${targetDirectory}/${entry.name}`, buffer.bytes({ copy: false }));
      } else {
        entry.body.autodrain();
      }
    }
  }
}

async function fileExists(filename: string) {
  return (await Deno.lstat(`${targetDirectory}/${filename}`)).isFile
}

switch (os) {
  case 'linux': {
    const library = 'libduckdb.so';
    if (await fileExists(library)) break;
    console.log(`Downloading ${library}`);
    await extractFilesFromZip('https://github.com/duckdb/duckdb/releases/download/v0.8.1/libduckdb-linux-amd64.zip', [library]);
    break;
  }
  default:
    console.error(`Unsupported Operating System ${os}`);
    break;
}
