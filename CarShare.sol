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
        string registerationPlates;
        string brand;
        string model;
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

        // adding address to list of drivers
        drivers.push(msg.sender);

        // creating a driver with input arguments
        Driver storage driver = listOfDrivers[msg.sender];
        driver.driverAddress = msg.sender;
        driver.firstName = _firstName;
        driver.lastName = _lastName;
        driver.accountBalance = msg.sender.balance;
    }

    //adding a vehicle
    function addVehicle(string _brand, string _registrationPlates,
        string _model, uint _hourlyPrice, address _owner) public {
        // adding address to a list of vehicles
        vehicles.push(msg.sender);

        // creating a Vehicle with inputs
        Vehicle storage vehicle = listOfVehicles[msg.sender];
        vehicle.vehicleAddress = msg.sender;
        vehicle.registerationPlates = _registrationPlates;
        vehicle.brand = _brand;
        vehicle.model = _model;
        vehicle.hourlyPrice = _hourlyPrice; //in wei
        vehicle.availability = true;
        vehicle.owner = _owner;
        vehicle.currentDriver = 0x0;
        vehicle.timeOfNextAvailability = 0;
        vehicle.startOfLastDrive = 0;
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
            listOfVehicles[_vehicleAddress].registerationPlates,
            listOfVehicles[_vehicleAddress].brand,
            listOfVehicles[_vehicleAddress].model,
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
        //It is required that the vehicle is availble
        require(listOfVehicles[_vehicleAddress].availability == true);

        //Amount of wei that needs to send to rent a vehicle
        //for certain amount of hours
        uint totalPrice = listOfVehicles[_vehicleAddress].hourlyPrice * _numberOfHours;

        //Checking if amoount sends is right
        if(msg.value == totalPrice){
            listOfVehicles[_vehicleAddress].availability = false;
            listOfVehicles[_vehicleAddress].timeOfNextAvailability = block.timestamp + (3600 * _numberOfHours);
            listOfVehicles[_vehicleAddress].currentDriver = msg.sender;
            listOfVehicles[_vehicleAddress].startOfLastDrive = now;
            _vehicleAddress.transfer(totalPrice);
            setAvailableVehicles();
        }

    }

    //Ending drive drive - function that is called from remote server
    //Checks if admin is caling it and that the time of rent has expired
    function endDrive(address _vehicleAddress) isAdmin public {
        require(now >= block.timestamp);

        //Setting vehicle to be available
        listOfVehicles[_vehicleAddress].availability = true;
        listOfVehicles[_vehicleAddress].timeOfNextAvailability = 0;
        listOfVehicles[_vehicleAddress].currentDriver = 0x0;
        listOfVehicles[_vehicleAddress].startOfLastDrive = 0;
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

    function setAvailableVehicles() public {

        availableVehicles = new address[](0);
        address currentAddress;
        for(uint i = 0; i < vehicles.length; i++) {
            currentAddress = vehicles[i];
            if (listOfVehicles[currentAddress].availability == true) {
                availableVehicles.push(currentAddress);
            }
        }
    }

    function getAvailableVehicles() public view returns(address[]){
        return availableVehicles;
    }


}
