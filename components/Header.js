import React from 'react';
import { Menu } from 'semantic-ui-react';
import { Link } from '../routes';

export default () => {
  return (
    <Menu style={{ marginTop: '10px' }}>
      <Link route="/">
        <a className="item">
          	<h3>CarShare</h3>
        </a>
      </Link>
      <Link route="/vehicles/availableVehicles">
        <a className="item">
          <h4>Available vehicles</h4>
        </a>
      </Link>

      <Menu.Menu position="right">
        <Link route="/vehicles/registeredVehicles">
          <a className="item">
            <h5>Registered Vehicles</h5>
          </a>
        </Link>
        <Link route="/drivers/registeredDrivers">
          <a className="item">
            <h5>Registered Drivers</h5>
          </a>
        </Link>
      </Menu.Menu>
    </Menu>
  );
};
