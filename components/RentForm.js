import React, { Component } from 'react';
import { Form, Input, Message, Button } from 'semantic-ui-react';
import web3 from '../ethereum/web3';
import carsharing from '../ethereum/carsharing';
import { Router } from '../routes';

class RentForm extends Component {
  state = {
    numberofhours: 0,
    hourlyPrice: 0,
    errorMessage: '',
    loading: false
  };

  onSubmit = async event => {
    event.preventDefault();

    const address = this.props.address;
    const hourlyPrice = web3.utils.toWei(this.props.hourlyPrice, 'ether');
    const numberofhours = this.state.numberofhours;
    this.setState({ loading: true });
    if(numberofhours <= 0) {
      this.setState({errorMessage: 'Number of hours needs to specified.', loading: false });
      return(err);
    } else {
    try {
      const accounts = await web3.eth.getAccounts();
      const value = (numberofhours * hourlyPrice);
      await carsharing.methods.rentAVehicle(address, numberofhours).send({
        from: accounts[0],
        value: value
      });
      Router.replaceRoute(`/vehicles/${this.props.address}`);
    } catch (err) {
      this.setState({ errorMessage: err.message });
    }

    this.setState({ loading: false,  numberofhours: 0});
    }
  };

  render() {
    return (
      <Form onSubmit={this.onSubmit} error={!!this.state.errorMessage}>
        <Form.Field>
          <label>Number of hours you want to rent the vehicle</label>
          <Input
            numberofhours={this.state.numberofhours}
            onChange={event => this.setState({ numberofhours: event.target.value })}
            label="hours"
            labelPosition="right"
          />
        </Form.Field>
        <Message error header={"Oops!"} content={this.state.errorMessage} />
        <Button primary loading={this.state.loading}>
          Rent
        </Button>
      </Form>
    );
  }
}

export default RentForm;
