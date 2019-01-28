pragma solidity ^0.4.20;

contract CarSharing {

    address public admin;

    //Seting admin address to the account that creates smart contract
    function CarSharing() public {
        admin = msg.sender;
    }

    modifier isAdmin() {
        require(msg.sender == admin);
        _;
    }

    // Declaring Driver data type
    struct Driver {
        address driverAddress;
        string firstName;
        string lastName;
        uint accountBalance;
    }

    // list of drivers adresses
    address[] public drivers;

    // mapping drivers address with struct Driver
    mapping(address => Driver) public listOfDrivers;

    // Declaring Vehicle data type
    struct Vehicle {
        address vehicleAddress;
        string brand;
        string model;
        string registerationPlates;
        uint hourlyPrice;
        bool availability;
        address owner;
        address currentDriver;
        uint timeOfNextAvailability;
        uint startOfLastDrive;
    }

    // list of vehicle addresses
    address[] public vehicles;

    // mapping vehicle address with struct Vehicle
    mapping(address => Vehicle) public listOfVehicles;

    address[] public availableVehicles;

    // adding a driver
    function addDriver(string _firstName, string _lastName) public {
        //Check to see if address is already used
        if(listOfDrivers[msg.sender].driverAddress == 0x0
        && listOfVehicles[msg.sender].vehicleAddress == 0x0) {
        // adding address to list of drivers
            drivers.push(msg.sender);

            // creating a driver with input arguments
            Driver storage driver = listOfDrivers[msg.sender];
            driver.driverAddress = msg.sender;
            driver.firstName = _firstName;
            driver.lastName = _lastName;
            driver.accountBalance = msg.sender.balance;
        } else {
            revert();
        }
    }

    //adding a vehicle
    function addVehicle(string _brand, string _model,
        string _registrationPlates, uint _hourlyPrice, address _owner) public {
        if(listOfDrivers[msg.sender].driverAddress == 0x0
        && listOfVehicles[msg.sender].vehicleAddress == 0x0) {
            // adding address to a list of vehicles
            vehicles.push(msg.sender);

            // creating a Vehicle with inputs
            Vehicle storage vehicle = listOfVehicles[msg.sender];
            vehicle.vehicleAddress = msg.sender;
            vehicle.brand = _brand;
            vehicle.model = _model;
            vehicle.registerationPlates = _registrationPlates;
            vehicle.hourlyPrice = _hourlyPrice; //in wei
            vehicle.availability = true;
            vehicle.owner = _owner;
            vehicle.currentDriver = 0x0;
            vehicle.timeOfNextAvailability = 0;
            vehicle.startOfLastDrive = 0;
            availableVehicles.push(msg.sender);
        } else {
            revert();
        }
    }

        // retirieve an array with addresses of all vehicles
    function retrieveVehicles() public view returns(address[]) {
        return vehicles;
    }

    // retrieve an array of address that contains all addresses
    function retrieveDrivers() public view returns(address[]){
        return drivers;
    }

    // retrieve a driver with an address parameter
    function retrieveADriver(address _driverAddress) public view returns(
        string,
        string,
        uint
        )
        {
        return (
            listOfDrivers[_driverAddress].firstName,
            listOfDrivers[_driverAddress].lastName,
            listOfDrivers[_driverAddress].accountBalance
        );
    }

    // retrieve a vehicle with an address
    function retrieveAVehicle(address _vehicleAddress) public view returns(
        string,
        string,
        string,
        uint,
        bool
    ) {
        return (
            listOfVehicles[_vehicleAddress].brand,
            listOfVehicles[_vehicleAddress].model,
            listOfVehicles[_vehicleAddress].registerationPlates,
            listOfVehicles[_vehicleAddress].hourlyPrice,
            listOfVehicles[_vehicleAddress].availability
        );
    }

    // retrieve additional vehicle information
    function retrieveVehicleInfo(address _vehicleAddress) public view returns (
        address,
        address,
        uint,
        uint
    ) {
        return (
            listOfVehicles[_vehicleAddress].owner,
            listOfVehicles[_vehicleAddress].currentDriver,
            listOfVehicles[_vehicleAddress].timeOfNextAvailability,
            listOfVehicles[_vehicleAddress].startOfLastDrive
        );
    }

    //address and number of hours wanted to rent a vehicle are needed
    //to rent a vehicle
    function rentAVehicle(address _vehicleAddress, uint _numberOfHours)
        public payable{
        //Check to see if address is registered as driver
        if(listOfDrivers[msg.sender].driverAddress != 0x0){
            //It is required that the vehicle is availble
            require(listOfVehicles[_vehicleAddress].availability == true);

            //Amount of wei that needs to send to rent a vehicle
            //for certain amount of hours
            uint totalPrice = listOfVehicles[_vehicleAddress].hourlyPrice * _numberOfHours;

            //Checking if amoount sends is right
            if(msg.value == totalPrice){
                Vehicle storage vehicle = listOfVehicles[_vehicleAddress];
                vehicle.availability = false;
                vehicle.timeOfNextAvailability = block.timestamp + (3600 * _numberOfHours);
                vehicle.currentDriver = msg.sender;
                vehicle.startOfLastDrive = now;
                _vehicleAddress.transfer(totalPrice);
                removeFromAvailableVehicles(_vehicleAddress);
            } else {
                revert();
            }
        } else {
            revert();
        }

    }

    //Ending drive drive - function that is called from remote server
    //Checks if admin is caling it and that the time of rent has expired
    function endDrive(address _vehicleAddress) public {
        require(now >= listOfVehicles[_vehicleAddress].timeOfNextAvailability &&
        (msg.sender == admin || msg.sender == listOfVehicles[_vehicleAddress].currentDriver));

        Vehicle storage vehicle = listOfVehicles[_vehicleAddress];

        //Setting vehicle to be available
        vehicle.availability = true;
        vehicle.timeOfNextAvailability = 0;
        vehicle.currentDriver = 0x0;
        vehicle.startOfLastDrive = 0;
    }

    function timeTillEndOfRent(address _vehicleAddress)
    public view returns(uint) {
        uint end =
        (listOfVehicles[_vehicleAddress].timeOfNextAvailability
        - listOfVehicles[_vehicleAddress].startOfLastDrive) / 3600;
        return end;
    }

    function numberOfDrivers() public view returns(uint) {
        return drivers.length;
    }

    function numberOfVehicles() public view returns(uint) {
        return vehicles.length;
    }

    function removeFromAvailableVehicles(address _vehicleAddress) public {
        for (uint i = 0; i < availableVehicles.length; i++){
            if(_vehicleAddress == availableVehicles[i]){
                address keyToMove = availableVehicles[availableVehicles.length-1];
                availableVehicles[i] = keyToMove;
                availableVehicles.length--;
            }
        }
    }

    function getAvailableVehicles() public view returns(address[]){
        return availableVehicles;
    }

    function editDriverFirstName(
        address _driverAddress,
        string _newFirstName
        )
        public {
        require(msg.sender == listOfDrivers[_driverAddress].driverAddress);

        Driver storage driver = listOfDrivers[_driverAddress];

        driver.firstName = _newFirstName;
        }

    function editDriverLastName(
        address _driverAddress,
        string _newLastName)
        public {
        require(msg.sender == listOfDrivers[_driverAddress].driverAddress);

        Driver storage driver = listOfDrivers[_driverAddress];

        driver.lastName = _newLastName;
        }

    function editVehicleBrand(address _vehicleAddress, string _newBrand) public {
        require(msg.sender == listOfVehicles[_vehicleAddress].owner);

        listOfVehicles[_vehicleAddress].brand = _newBrand;
    }

    function editVehicleModel(address _vehicleAddress, string _newModel) public {
        require(msg.sender == listOfVehicles[_vehicleAddress].owner);

        listOfVehicles[_vehicleAddress].model = _newModel;
    }

    function editVehicleRegistrationPlates(address _vehicleAddress, string _newRegistrationPlates) public {
        require(msg.sender == listOfVehicles[_vehicleAddress].owner);

        listOfVehicles[_vehicleAddress].registerationPlates = _newRegistrationPlates;
    }

    function editVehicleHourlyPrice(address _vehicleAddress, uint _newHourlyPrice) public {
       require(msg.sender == listOfVehicles[_vehicleAddress].owner);

        listOfVehicles[_vehicleAddress].hourlyPrice = _newHourlyPrice;
    }

    function editVehicleOwner(address _vehicleAddress, address _newOwner) public {
        require(msg.sender == listOfVehicles[_vehicleAddress].owner);

        listOfVehicles[_vehicleAddress].owner = _newOwner;
    }

    function deleteDriver(address _driverAddress) public {
        require(msg.sender == listOfDrivers[_driverAddress].driverAddress);

        Driver storage driver = listOfDrivers[_driverAddress];

        driver.driverAddress = 0x0;
        driver.firstName = '';
        driver.lastName = '';
        driver.accountBalance = 0;

        for(uint i = 0; i < drivers.length; i++){
            if(_driverAddress == drivers[i]){
                address keyToMove = drivers[drivers.length-1];
                drivers[i] = keyToMove;
                drivers.length--;
            }
        }
    }

    function deleteVehicle(address _vehicleAddress) public {
        require(msg.sender == listOfVehicles[_vehicleAddress].owner);

        Vehicle storage vehicle = listOfVehicles[_vehicleAddress];

        vehicle.vehicleAddress = 0x0;
        vehicle.brand = '';
        vehicle.model = '';
        vehicle.registerationPlates = '';
        vehicle.hourlyPrice = 0;
        vehicle.availability = false;
        vehicle.owner = 0x0;
        vehicle.currentDriver = 0x0;
        vehicle.timeOfNextAvailability = 0;
        vehicle.startOfLastDrive = 0;

        for(uint i = 0; i < vehicles.length; i++){
            if(_vehicleAddress == vehicles[i]){
               address keyToMove = vehicles[vehicles.length-1];
               vehicles[i] = keyToMove;
               vehicles.length--;
            }
        }
    }

}
