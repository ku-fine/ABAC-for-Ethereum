// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Base.sol";
import "./ACBF.sol";
import "./OAMC.sol";
import "./SAMC.sol";
import "./BloomFilter.sol";
import "./Cache.sol";

contract GRB is Base{
    using Cache for Cache.CacheList;
    using BloomFilter for BloomFilter.Filter;

    ACBF pmc = ACBF(0xfDae559f53daeDdEc7033768b80C45fFD14A31e4);
    OAMC oamc = OAMC(0xa13862cFd27bC61378Ce0e8fc1E3326f70174e5c);
    SAMC samc = SAMC(0x85D601869E4E5F180005784c4E76fF12626B8c9D);

    Cache.CacheList cache;
    BloomFilter.Filter filter;

    constructor() {
        filter.init(10000, 7);
    }

    function getSubjectAttribute(string calldata id) public view returns(string memory, string memory) {
        return (samc.getSubject(id).name, samc.getSubject(id).role);
    }

    function getObjectAttribute(string calldata id) public view returns(string memory, string memory) {
        return (oamc.getObject(id).name, oamc.getObject(id).place);
    }

    function getStart() public view returns(uint) {
        return (cache.start);
    }

    function getPolicy(string memory subjectName, string memory role, string memory objectName, string memory place) public returns(bool, bool, bool){
        if(filter.check(subjectName, role, objectName, place)) {
            int indexCache = cache.check(SubjectAttribute(subjectName, role), ObjectAttribute(objectName, place));
            if(indexCache < 0) {
                int[] memory index = pmc.findMatchPolicy(SubjectAttribute(subjectName, role), ObjectAttribute(objectName, place));
                if(index.length == 1){
                    if(index[0] < 0){
                        return (false, false, false);
                    }
                    else{
                        Policy memory policy = pmc.getPolicy(uint(index[0]));
                        if(block.timestamp >= policy.context.start && block.timestamp <= policy.context.end){
                            bool flagRemoval = false;
                           Policy memory removedPolicy;
                            filter.add(policy.subject.attribute.name, policy.subject.attribute.role, policy.object.attribute.name, policy.object.attribute.place);
                            (flagRemoval, removedPolicy) = cache.add(policy);
                            if(flagRemoval) {
                                filter.remove(removedPolicy.subject.attribute.name, removedPolicy.subject.attribute.role, removedPolicy.object.attribute.name, removedPolicy.object.attribute.place);
                            }
                            return (policy.action.read, policy.action.write, policy.action.execute);
                        }
                        else{
                            return (false, false, false);
                        }
                    }
                }
                else{
                    return (false, false, false);
                }
            }
            else {
                Policy memory policy = cache.buffer[uint(indexCache)];
                if(block.timestamp >= policy.context.start && block.timestamp <= policy.context.end){
                    cache.update(uint(indexCache));
                    return (policy.action.read, policy.action.write, policy.action.execute);
                }
                else{
                    return (false, false, false);
                }
            }
        }
        else {
            int[] memory index = pmc.findMatchPolicy(SubjectAttribute(subjectName, role), ObjectAttribute(objectName, place));
                if(index.length == 1){
                    if(index[0] < 0){
                        return (false, false, false);
                    }
                    else{
                        Policy memory policy = pmc.getPolicy(uint(index[0]));
                        if(block.timestamp >= policy.context.start && block.timestamp <= policy.context.end){
                            bool flagRemoval = false;
                            Policy memory removedPolicy;
                            filter.add(policy.subject.attribute.name, policy.subject.attribute.role, policy.object.attribute.name, policy.object.attribute.place);
                            (flagRemoval, removedPolicy) = cache.add(policy);
                            if(flagRemoval) {
                                filter.remove(removedPolicy.subject.attribute.name, removedPolicy.subject.attribute.role, removedPolicy.object.attribute.name, removedPolicy.object.attribute.place);
                            }
                            return (policy.action.read, policy.action.write, policy.action.execute);
                        }
                        else{
                            return (false, false, false);
                        }
                    }
                }
                else{
                    return (false, false, false);
                }
        }
    }

    function getAccessResult(string calldata subjectId, string calldata objectId) public returns(bool, bool, bool){
        string memory subjectName;
        string memory role;
        string memory objectName;
        string memory place;

        (subjectName, role) = getSubjectAttribute(subjectId);
        (objectName, place) = getObjectAttribute(objectId);

        bool read = false;
        bool write = false;
        bool execute = false;

        (read, write, execute) = getPolicy(subjectName, role, objectName, place);

        return (read, write, execute);

    }

    function addPolicy(Subject calldata subject, Object calldata object, Action calldata action, Context calldata context) public returns(SubjectAttribute memory, ObjectAttribute memory, Policy[] memory) {
        samc.addSubject(subject.id, subject.attribute.name, subject.attribute.role);
        oamc.addObject(object.id, object.attribute.name, object.attribute.place);
        pmc.addPolicy(subject, object, action, context);

        SubjectAttribute memory s = samc.getSubject(subject.id);
        ObjectAttribute memory o = oamc.getObject(object.id);
        Policy[] memory p = pmc.getPolicies();

        return(s, o, p);
    }
}
