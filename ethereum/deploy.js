const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
const CarShare = require('./build/CarSharing');

const provider = new HDWalletProvider(
  'hole glance glimpse rubber salt picnic marble car very wreck cargo virus',
  'https://rinkeby.infura.io/z9TH3Y9RbANwEIWXdTLk'
);
const web3 = new Web3(provider);

const deploy = async () => {
  const accounts = await web3.eth.getAccounts();

  console.log('Attempting to deploy from account', accounts[0]);

  const result = await new web3.eth.Contract(JSON.parse(CarShare.interface))
    .deploy({ data: '0x' + CarShare.bytecode })
    .send({ from: accounts[0], gas: '3000000' });

  console.log('Contract deployed to ', result.options.address);
};
deploy();
