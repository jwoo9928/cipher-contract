// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ChatRoom {
    struct Room {
        mapping(address => bool) members;
        address owner;
        uint256 maxFileSize;
        uint256 totalPayment;
    }

    mapping(bytes32 => Room) public rooms;
    mapping(bytes32 => mapping(address => bytes)) public signatures;

    event RoomCreated(bytes32 indexed roomId, address indexed owner);
    event MemberJoined(bytes32 indexed roomId, address indexed member, bytes signature);
    event FileSizeIncreased(bytes32 indexed roomId, uint256 newSize);

    function createRoom(bytes32 roomId) public {
        require(!isMember(roomId, msg.sender), "Already a member of the room");
        Room storage room = rooms[roomId];
        room.members[msg.sender] = true;
        room.owner = msg.sender;
        room.maxFileSize = 1e9; // 1GB
        emit RoomCreated(roomId, msg.sender);
    }

    function joinRoom(bytes32 roomId, bytes memory signature) public {
        require(!isMember(roomId, msg.sender), "Already a member of the room");
        signatures[roomId][msg.sender] = signature;
        rooms[roomId].members[msg.sender] = true;
        emit MemberJoined(roomId, msg.sender, signature);
    }

    function contributeToIncreaseFileSize(bytes32 roomId) public payable {
        require(isMember(roomId, msg.sender), "Not a member of the room");
        Room storage room = rooms[roomId];
        room.totalPayment += msg.value;

        if (room.totalPayment >= 0.001 ether) {
            room.maxFileSize = 5e9; // 5GB
            room.totalPayment = 0; // Reset the total payment
            emit FileSizeIncreased(roomId, 5e9);
        }
    }

    function isMember(bytes32 roomId, address user) public view returns (bool) {
        return rooms[roomId].members[user];
    }

    function isOwner(bytes32 roomId, address user) public view returns (bool) {
        return rooms[roomId].owner == user;
    }
}