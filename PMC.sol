// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Base.sol";

contract PMC is Base{

    Policy[] policyList;

    function getPolicy(uint index) public view returns(Policy memory){
        return policyList[index];
    }

    function getPolicies() public view returns(Policy[] memory){
        return policyList;
    }

    function addPolicy(Subject calldata subject, Object calldata object, Action calldata action, Context calldata context) public returns(bool, int[] memory){
        int[] memory flag = findMatchPolicy(subject.attribute, object.attribute);
        if(flag[0] == -1) {
            policyList.push(Policy(subject, object, action, context));
            return (true, flag);
        }
        return (false, flag);
    }

    function updatePolicy(Subject calldata subject, Object calldata object, Action calldata action, Context calldata context) public returns(bool, int[] memory){
        int[] memory flag = findMatchPolicy(subject.attribute, object.attribute);
        if(flag[0] == -1) {
            return (false, flag);
        }
        if(flag.length == 1){
            policyList[uint(flag[0])] = Policy(subject, object, action, context);
            return (true, flag);
        }
        else {
            return (false, flag);
        }
    }

    function deletePolicy(Subject calldata subject, Object calldata object) public returns(bool) {
        int flag = findExactMatchPolicy(subject.attribute, object.attribute);
        if(flag != -1) {
            delete policyList[uint(flag)];
            return true;
        }
        return false;
    }

    function findMatchPolicy(SubjectAttribute calldata sa, ObjectAttribute calldata oa) public view returns(int[] memory){
        uint count = 0;
        uint policyLength = policyList.length;
        int[] memory index = new int[](policyLength);
        for(uint i = 0; i < policyLength; i++) {
            if(keccak256(abi.encodePacked(sa.name)) != keccak256(abi.encodePacked("*")) && keccak256(abi.encodePacked(sa.name)) != keccak256(abi.encodePacked(policyList[i].subject.attribute.name)) && keccak256(abi.encodePacked(policyList[i].subject.attribute.name)) != keccak256(abi.encodePacked("*"))) {
                continue;
            }
            if(keccak256(abi.encodePacked(sa.role)) != keccak256(abi.encodePacked("*")) && keccak256(abi.encodePacked(sa.role)) != keccak256(abi.encodePacked(policyList[i].subject.attribute.role)) && keccak256(abi.encodePacked(policyList[i].subject.attribute.role)) != keccak256(abi.encodePacked("*"))) {
                continue;
            }
            if(keccak256(abi.encodePacked(oa.name)) != keccak256(abi.encodePacked("*")) && keccak256(abi.encodePacked(oa.name)) != keccak256(abi.encodePacked(policyList[i].object.attribute.name)) && keccak256(abi.encodePacked(policyList[i].object.attribute.name)) != keccak256(abi.encodePacked("*"))) {
                continue;
            }
            if(keccak256(abi.encodePacked(oa.place)) != keccak256(abi.encodePacked("*")) && keccak256(abi.encodePacked(oa.place)) != keccak256(abi.encodePacked(policyList[i].object.attribute.place)) && keccak256(abi.encodePacked(policyList[i].object.attribute.place)) != keccak256(abi.encodePacked("*"))) {
                continue;
            }
            index[count] = int(i);
            count++;
        }
        if(count == 0) {
            int[] memory arrayMemory = new int[](1);
            arrayMemory[0] = -1;
            return arrayMemory;
        }
        else{
            int[] memory arrayMemory = new int[](count);
            for(uint i = 0; i < count; i++){
                arrayMemory[i] = index[i];
            }
            return arrayMemory;
        }
    }

    function findExactMatchPolicy(SubjectAttribute calldata sa, ObjectAttribute calldata oa) public view returns(int) {
        int index = -1;
        uint policyLength = policyList.length;
        for(uint i = 0; i < policyLength; i++) {
            if(keccak256(abi.encodePacked(sa.name)) != keccak256(abi.encodePacked(policyList[i].subject.attribute.name))) {
                continue;
            }
            if(keccak256(abi.encodePacked(sa.role)) != keccak256(abi.encodePacked(policyList[i].subject.attribute.role))) {
                continue;
            }
            if(keccak256(abi.encodePacked(oa.name)) != keccak256(abi.encodePacked(policyList[i].object.attribute.name))) {
                continue;
            }
            if(keccak256(abi.encodePacked(oa.place)) != keccak256(abi.encodePacked(policyList[i].object.attribute.place))) {
                continue;
            }
            index = int(i);
            break;
        }
        return index;
    } 


}