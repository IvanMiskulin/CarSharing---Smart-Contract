const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());

const compiledCarShare = require('../ethereum/build/CarShare.json');

let accounts;
let carShare;

beforeEach(async () => {
  accounts = await web3.eth.getAccounts();

  carShare = await new web3.eth.Contract(JSON.parse(compiledCarShare.interface))
    .deploy({ data: compiledCarShare.bytecode})
    .send({ from: accounts[0], gas: '1000000'});
});

describe('Car share', () => {
  it('deploys a car share', async () => {
    assert.ok(carShare.options.address);
  });

  it('adds a driver', async () => {
    await carShare.methods.dodajVozaca(
      "0xca35b7d915458ef540ade6068dfe2f44e8fa733c",
      "Ivan",
      "M",
      "0"
    )
    .send({
      from: accounts[0],
      gas: '1000000'
      });
    });

    it('adds a vehicle', async () => {
      await carShare.methods.dodajVozilo(
        "0xca35b7d915458ef540ade6068dfe2f44e8fa733c",
        "mercedes",
        true,
        "ivan",
        "120"
      )
      .send({
        from: accounts[0],
        gas: '1000000'
      });
    });
});
