import web3 from './web3';
import CarSharing from './build/CarSaring.json';

export default (address) => {
  return new web3.eth.Contract(
    JSON.parse(CarSharing.interface),
    address
  );
};
