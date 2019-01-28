// First compile script
/*
const path = require('path');
const fs = require('fs-extra');
const solc = require('solc');

const carsharingPath = path.resolve(__dirname, 'contracts', 'CarSharing.sol');
const source = fs.readFileSync(carsharingPath, 'utf8');

module.exports = solc.compile(source,1).contracts[':CarShare'];
*/

// Better compile script

const path = require('path');
const solc = require('solc');
const fs = require('fs-extra');

const buildPath = path.resolve(__dirname, 'build');
fs.removeSync(buildPath);

const carsharingPath = path.resolve(__dirname, 'contracts', 'CarSharing.sol');
const source = fs.readFileSync(carsharingPath, 'utf8');

const output = solc.compile(source, 1).contracts;

fs.ensureDirSync(buildPath);

for (let contract in output) {
  fs.outputJsonSync(
    path.resolve(buildPath, contract.replace(':', '') + '.json'),
    output[contract]
  );
}
