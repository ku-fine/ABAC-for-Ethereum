// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Base.sol";

contract SAMC is Base{
    mapping(string => Subject) subjectList;

    function addSubject(string calldata id, string calldata name, string calldata role) public {
        subjectList[id].id = id;
        subjectList[id].attribute.name = name;
        subjectList[id].attribute.role = role;
    }

    function deleteSubject(string calldata id) public {
        delete subjectList[id];
    }
    function getSubject(string calldata id) public view returns(SubjectAttribute memory) {
        SubjectAttribute memory a = subjectList[id].attribute;
        return a;
    }

}

