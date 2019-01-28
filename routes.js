const routes = require('next-routes')();

routes
  .add('/drivers/registeredDrivers', '/drivers/registeredDrivers')
  .add('/vehicles/registeredVehicles', '/vehicles/registeredVehicles')
  .add('/drivers/new', '/drivers/new')
  .add('/vehicles/new', '/vehicles/new')
  .add('/vehicles/availableVehicles', '/vehicles/availableVehicles')
  .add('/drivers/editDriver', '/drivers/editDriver')
  .add('/drivers/:address', '/drivers/show')
  .add('/drivers/:address/editDriver', '/drivers/editDriver')
  .add('/vehicles/:address', '/vehicles/show');

module.exports = routes;
