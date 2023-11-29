// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title Hotel booking contract
 * @notice Do not use this contract in production
 */
contract HotelBooking {
    // Variables
    address public owner;

    // Data structures
    struct Hotel {
        uint basePricePerDay; // In weis
        bool registered;
        Booking[] bookings;
    }

    struct Booking {
        address customer;
        RoomType roomType;
        uint bookingDays;
    }

    enum RoomType {
        Single,
        Double,
        Suite
    }

    // Hotel information (mapping)
    mapping(string => Hotel) public hotels;

    constructor() {
        owner = msg.sender;
    }

    // Modifiers
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function"
        );
        _;
    }

    // Functions
    function registerHotel(
        string memory hotelName,
        uint _basePricePerDay
    ) public onlyOwner {
        require(!hotels[hotelName].registered, "Hotel already registered");
        require(
            _basePricePerDay > 0,
            "Base price per day must be higher than 0"
        );

        hotels[hotelName].basePricePerDay = _basePricePerDay;
        hotels[hotelName].registered = true;
    }

    function bookHotel(
        string memory hotelName,
        RoomType _roomType,
        uint _bookingDays
    ) public payable {
        require(hotels[hotelName].registered, "Hotel not registered");
        require(_bookingDays > 0, "Booking days must be higher than 0");
        require(
            msg.value >=
                estimateBookingPrice(hotelName, _roomType, _bookingDays),
            "Not enough weis"
        );

        Booking memory b;
        b.customer = msg.sender;
        b.roomType = _roomType;
        b.bookingDays = _bookingDays;

        hotels[hotelName].bookings.push(b);
    }

    function estimateBookingPrice(
        string memory hotelName,
        RoomType _roomType,
        uint _bookingDays
    ) public view returns (uint) {
        uint multiplier = 1;

        if (_roomType == RoomType.Double) {
            multiplier = 2;
        } else if (_roomType == RoomType.Suite) {
            multiplier = 3;
        }

        return hotels[hotelName].basePricePerDay * multiplier * _bookingDays;
    }

    function getHotelBookings(
        string memory hotelName
    ) public view returns (Booking[] memory) {
        return hotels[hotelName].bookings;
    }
}
