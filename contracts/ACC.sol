// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Base.sol";
import "./PMC.sol";
import "./OAMC.sol";
import "./SAMC.sol";



contract ACC is Base{
    PMC pmc = PMC(0x6B931C1Ee13C018CE43Fb64AB0Adb0eb535ACc12);
    OAMC oamc = OAMC(0xb050a80549E12065274f21d26301a21FF10F2186);
    SAMC samc = SAMC(0x114e680EA6f066230DFDB50584a93F45f2f43a12);

    function getSubjectAttribute(string calldata id) public view returns(string memory, string memory) {
        return (samc.getSubject(id).name, samc.getSubject(id).role);
    }

    function getObjectAttribute(string calldata id) public view returns(string memory, string memory) {
        return (oamc.getObject(id).name, oamc.getObject(id).place);
    }

    function getPolicy(string memory subjectName, string memory role, string memory objectName, string memory place) public view returns(bool, bool, bool){
        int[] memory index = pmc.findMatchPolicy(SubjectAttribute(subjectName, role), ObjectAttribute(objectName, place));
        if(index.length == 1) {
            if(index[0] < 0){
            return (false, false, false);
            }
            else{
                Policy memory policy = pmc.getPolicy(uint(index[0]));
                if(block.timestamp >= policy.context.start && block.timestamp <= policy.context.end){
                    return (policy.action.read, policy.action.write, policy.action.execute);
                }
                else{
                    return (false, false, false);
                }
            }
        }
        else {
            return (false, false, false);
        }
    }

    function getAccessResult(string calldata subjectId, string calldata objectId) public view returns(bool, bool, bool){
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
}