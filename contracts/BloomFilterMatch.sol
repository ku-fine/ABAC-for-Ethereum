// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 < 0.9.0;

library BloomFilterMatch {
    struct MatchPolicy{
        uint count;
        bool subjectName;
        bool role;
        bool objectName;
        bool place;
    }

    struct Filter{
        uint[] filter;
        MatchPolicy[] matchPolicies;
        uint size;
        uint numberOfHashFunctions;
    }
    
    // k = 0.7 * size / expected element
    function init(Filter storage filter, uint size, uint numberOfHashFunctions) internal{
        filter.filter = new uint[](size);
        filter.size = size;
        // uint numberOfHashFunctions = 0.7 * 0.001 * size;
        // if(numberOfHashFunctions > 0) {
        //     filter.numberOfHashFunctions = numberOfHashFunctions;
        // }
        // else {
        //     filter.numberOfHashFunctions = 1;
        // }
        filter.numberOfHashFunctions = numberOfHashFunctions;
    }

    function add(Filter storage filter, string calldata subjectName, string calldata role, string calldata objectName, string calldata place) internal{
        MatchPolicy memory mP = MatchPolicy(1, (keccak256(abi.encodePacked(subjectName)) == keccak256(abi.encodePacked("*"))), (keccak256(abi.encodePacked(role)) == keccak256(abi.encodePacked("*"))), (keccak256(abi.encodePacked(objectName)) == keccak256(abi.encodePacked("*"))), (keccak256(abi.encodePacked(place)) == keccak256(abi.encodePacked("*"))));
        uint matchPoliciesLength = filter.matchPolicies.length;
        
        if((mP.subjectName || mP.role || mP.objectName || mP.place)) {
            if(matchPoliciesLength == 0){
                filter.matchPolicies.push(mP);
            }
            else {
                for(uint h = 0; h < matchPoliciesLength; h++) {
                    if(filter.matchPolicies[h].subjectName == mP.subjectName && filter.matchPolicies[h].role == mP.role && filter.matchPolicies[h].objectName == mP.objectName && filter.matchPolicies[h].place == mP.place) {
                        filter.matchPolicies[h].count += 1;
                        break;
                    }
                    if(h == matchPoliciesLength - 1) {
                        filter.matchPolicies.push(mP);
                    }
                }
            }
        }
        
        for(uint i = 0; i < filter.numberOfHashFunctions; i++) {
            uint256 position = uint256(keccak256(abi.encodePacked(subjectName, role, objectName, place, i))) % filter.size;
            require(position < filter.size, "Overflow error");
            filter.filter[position] += 1;
        }
    }

    function check(Filter storage filter, string memory subjectName, string memory role, string memory objectName, string memory place) internal view returns(bool probablyPresent){
        bool flag = true;
        uint256 position = filter.size;

        for(uint i = 0; i < filter.numberOfHashFunctions; i++) {
            position = uint256(keccak256(abi.encodePacked(subjectName, role, objectName, place, i))) % filter.size;
            require(position < filter.size, "Overflow error");

            if(filter.filter[position] <= 0) {
                flag = false;
                break;
            }
        }
        if(flag) {
            return true;
        }
        else {
            string[4] memory policy;

            for(uint j = 0; j < filter.matchPolicies.length; j++) {
                policy[0] = subjectName;
                policy[1] = role;
                policy[2] = objectName;
                policy[3] = place;

                if(filter.matchPolicies[j].count > 0) {
                    if(filter.matchPolicies[j].subjectName) {
                        policy[0] = "*";
                    }
                    
                    if(filter.matchPolicies[j].role) {
                        policy[1] = "*";
                    }
                
                    if(filter.matchPolicies[j].objectName) {
                        policy[2] = "*";
                    }
                    
                    if(filter.matchPolicies[j].place) {
                        policy[3] = "*";
                    }
                }

                for(uint k = 0; k < filter.numberOfHashFunctions; k++) {
                    position = uint256(keccak256(abi.encodePacked(policy[0], policy[1], policy[2], policy[3], k))) % filter.size;
                    require(position < filter.size, "Overflow error");

                    if(filter.filter[position] <= 0) break;
                    if(k == filter.numberOfHashFunctions - 1) return true;
                }
            }
            return false;
        }
    }

    function remove(Filter storage filter, string calldata subjectName, string calldata role, string calldata objectName, string calldata place) internal{
        MatchPolicy memory mP = MatchPolicy(1, (keccak256(abi.encodePacked(subjectName)) == keccak256(abi.encodePacked("*"))), (keccak256(abi.encodePacked(role)) == keccak256(abi.encodePacked("*"))), (keccak256(abi.encodePacked(objectName)) == keccak256(abi.encodePacked("*"))), (keccak256(abi.encodePacked(place)) == keccak256(abi.encodePacked("*"))));
        uint matchPoliciesLength = filter.matchPolicies.length;
        int update = 0;
        
        if((mP.subjectName || mP.role || mP.objectName || mP.place)) {
            if(matchPoliciesLength != 0){
                for(uint h = 0; h < matchPoliciesLength; h++) {
                    if(filter.matchPolicies[h].subjectName == mP.subjectName && filter.matchPolicies[h].role == mP.role && filter.matchPolicies[h].objectName == mP.objectName && filter.matchPolicies[h].place == mP.place) {
                        update = int(filter.matchPolicies[h].count);
                        require(update > 0, "That element is not included.");
                        update += -1;
                        filter.matchPolicies[h].count = uint(update);
                        break;
                    }
                }
            }
        }

        for(uint i = 0; i < filter.numberOfHashFunctions; i++) {
            uint256 position = uint256(keccak256(abi.encodePacked(subjectName, role, objectName, place, i))) % filter.size;
            require(position < filter.size, "Overflow error");
            update = int(filter.filter[position]);
            require(update > 0, "That element is not included.");
            update += -1;
            filter.filter[position] = uint(update);
        }
    }
}