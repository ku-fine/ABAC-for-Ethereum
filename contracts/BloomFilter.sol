// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 < 0.9.0;

library BloomFilter {
    struct Filter{
        uint[] filter;
        uint size;
        uint numberOfHashFunctions;
    }
    
    // k = 0.7 * size / expected element
    function init(Filter storage filter, uint size, uint numberOfHashFunctions) internal{
        filter.filter = new uint[](size);
        filter.size = size;
        // uint numberOfHashFunctions = 0.7 * 0.0001 * size;
        // if(numberOfHashFunctions > 0) {
        //     filter.numberOfHashFunctions = numberOfHashFunctions;
        // }
        // else {
        //     filter.numberOfHashFunctions = 1;
        // }
        filter.numberOfHashFunctions = numberOfHashFunctions;
    }

    function add(Filter storage filter, string memory subjectName, string memory role, string memory objectName, string memory place) internal{
        for(uint i = 0; i < filter.numberOfHashFunctions; i++) {
            uint256 position = uint256(keccak256(abi.encodePacked(subjectName, role, objectName, place, i))) % filter.size;
            require(position < filter.size, "Overflow error");
            filter.filter[position] += 1;
        }
    }

    function check(Filter storage filter, string memory subjectName, string memory role, string memory objectName, string memory place) internal view returns(bool probablyPresent){
        for(uint i = 0; i < filter.numberOfHashFunctions; i++) {
            uint256 position = uint256(keccak256(abi.encodePacked(subjectName, role, objectName, place, i))) % filter.size;
            require(position < filter.size, "Overflow error");

            if(filter.filter[position] <= 0) return false;
        }
        return true;
    }

    function remove(Filter storage filter, string memory subjectName, string memory role, string memory objectName, string memory place) internal{
        for(uint i = 0; i < filter.numberOfHashFunctions; i++) {
            uint256 position = uint256(keccak256(abi.encodePacked(subjectName, role, objectName, place, i))) % filter.size;
            require(position < filter.size, "Overflow error");
            int update = int(filter.filter[position]);
            require(update > 0, "That element is not included.");
            update += -1;
            filter.filter[position] = uint(update);
        }
    }
}