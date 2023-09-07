// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ChatRoom {
    struct Room {
        mapping(address => bool) members;
        uint256 maxFileSize;
        uint256 totalPayment;
    }

    mapping(bytes32 => Room) public rooms;

    event RoomCreated(bytes32 indexed roomId, address indexed creator);
    event MemberJoined(bytes32 indexed roomId, address indexed member);
    event FileSizeIncreased(bytes32 indexed roomId, uint256 newSize);

    function createRoom(bytes32 roomId) public {
        require(!isMember(roomId, msg.sender), "Already a member of the room");
        Room storage room = rooms[roomId];
        room.members[msg.sender] = true;
        room.maxFileSize = 1e9; // 1GB
        emit RoomCreated(roomId, msg.sender);
    }

    function joinRoom(bytes32 roomId) public {
        require(!isMember(roomId, msg.sender), "Already a member of the room");
        rooms[roomId].members[msg.sender] = true;
        emit MemberJoined(roomId, msg.sender);
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
}