// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Base.sol";
import "./BloomFilterMatch.sol";

contract ACBF is Base{
    using BloomFilterMatch for BloomFilterMatch.Filter;

    BloomFilterMatch.Filter filter;

    Policy[] policyList;

    constructor() {
        filter.init(10000, 7);
    }

    function getPolicy(uint index) public view returns(Policy memory){
        return policyList[index];
    }

    function getFilter() public view returns(BloomFilterMatch.Filter memory){
        return filter;
    }

    function getPolicies() public view returns(Policy[] memory){
        return policyList;
    }

    function getCheckResult(string memory subjectName, string memory role, string memory objectName, string memory place) public view returns(bool){
        return filter.check(subjectName, role, objectName, place);
    }

    function addPolicy(Subject calldata subject, Object calldata object, Action calldata action, Context calldata context) public returns(bool, int[] memory){
        BloomFilterMatch.MatchPolicy memory mP = BloomFilterMatch.MatchPolicy(1, (keccak256(abi.encodePacked(subject.attribute.name)) == keccak256(abi.encodePacked("*"))), (keccak256(abi.encodePacked(subject.attribute.role)) == keccak256(abi.encodePacked("*"))), (keccak256(abi.encodePacked(object.attribute.name)) == keccak256(abi.encodePacked("*"))), (keccak256(abi.encodePacked(object.attribute.place)) == keccak256(abi.encodePacked("*"))));

        if((mP.subjectName || mP.role || mP.objectName || mP.place)) {
            int[] memory flag = findMatchPolicy(subject.attribute, object.attribute);
            if(flag[0] == -1) {
                policyList.push(Policy(subject, object, action, context));
                filter.add(subject.attribute.name, subject.attribute.role, object.attribute.name, object.attribute.place);
                return (true, flag);
            }
            return (false, flag);
        }
        else {
            if(filter.check(subject.attribute.name, subject.attribute.role, object.attribute.name, object.attribute.place)) {
                int[] memory flag = findMatchPolicy(subject.attribute, object.attribute);
                if(flag[0] == -1) {
                    policyList.push(Policy(subject, object, action, context));
                    filter.add(subject.attribute.name, subject.attribute.role, object.attribute.name, object.attribute.place);
                    return (true, flag);
                }
                return (false, flag);
            }
            else {
                int[] memory flag = new int[](1);
                flag[0] = -2;
                policyList.push(Policy(subject, object, action, context));
                filter.add(subject.attribute.name, subject.attribute.role, object.attribute.name, object.attribute.place);
                return (true, flag);
            }
        }
    }

    function updatePolicy(Subject calldata subject, Object calldata object, Action calldata action, Context calldata context) public returns(bool, int[] memory){
        BloomFilterMatch.MatchPolicy memory mP = BloomFilterMatch.MatchPolicy(1, (keccak256(abi.encodePacked(subject.attribute.name)) == keccak256(abi.encodePacked("*"))), (keccak256(abi.encodePacked(subject.attribute.role)) == keccak256(abi.encodePacked("*"))), (keccak256(abi.encodePacked(object.attribute.name)) == keccak256(abi.encodePacked("*"))), (keccak256(abi.encodePacked(object.attribute.place)) == keccak256(abi.encodePacked("*"))));

        if((mP.subjectName || mP.role || mP.objectName || mP.place)) {
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
        else {
            if(filter.check(subject.attribute.name, subject.attribute.role, object.attribute.name, object.attribute.place)) {
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
            else {
                int[] memory flag = new int[](1);
                flag[0] = -2;
                return (false, flag);
            }
        }
    }

    function deletePolicy(Subject calldata subject, Object calldata object) public returns(bool) {
        if(filter.check(subject.attribute.name, subject.attribute.role, object.attribute.name, object.attribute.place)) {
                int flag = findExactMatchPolicy(subject.attribute, object.attribute);
                if(flag != -1) {
                    delete policyList[uint(flag)];
                    return true;
                }
                return false;
            }
            else {
                return false;
            }
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