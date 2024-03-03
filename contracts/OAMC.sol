// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Base.sol";

contract OAMC is Base{
    mapping(string => Object) objectList;

    function addObject(string calldata id, string calldata name, string calldata place) public {
        objectList[id].id = id;
        objectList[id].attribute.name = name;
        objectList[id].attribute.place = place;
    }

    function deleteObject(string calldata id) public {
        delete objectList[id];
    }
    function getObject(string calldata id) public view returns(ObjectAttribute memory) {
        ObjectAttribute memory a = objectList[id].attribute;
        return a;
    }

}

