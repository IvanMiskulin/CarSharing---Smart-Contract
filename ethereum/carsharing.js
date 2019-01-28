import web3 from './web3';
import CarSharing from './build/CarSharing.json';

const carsharing = new web3.eth.Contract(
JSON.parse(CarSharing.interface),
'0x13ED4968323405f98C90460eb9224EfE7Dff2222'
);

export default carsharing;
