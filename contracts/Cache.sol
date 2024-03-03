// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 < 0.9.0;

import "./Base.sol";

library Cache {
    struct CacheList {
        Base.Policy[] buffer;
        uint start;
    }

    uint16 constant maxSize = 500;

    function add(CacheList storage cache, Base.Policy calldata policy) external returns(bool, Base.Policy memory) {
        uint cacheLength = cache.buffer.length;
        Base.Policy memory removedPolicy;
        uint nextStart = (cache.start + 1) % maxSize;

        if(cacheLength == 0) {
            cache.buffer.push(policy);
            return(false, removedPolicy);
        }
        else if(cacheLength > 0 && cacheLength < maxSize) {
            cache.buffer.push(policy);
            cache.start = nextStart;
            return(false, removedPolicy);
        }
        else {
            removedPolicy = cache.buffer[nextStart];
            cache.buffer[nextStart] = policy;
            cache.start = nextStart;
            return(true, removedPolicy);
        }
    }

    function update(CacheList storage cache, uint index) external {
        if(index != cache.start) {
            uint nextIndex = (index + 1) % maxSize;
            Base.Policy memory tempPolicy = cache.buffer[index];
            cache.buffer[index] = cache.buffer[nextIndex];
            cache.buffer[nextIndex] = tempPolicy;
        }
    }

    function remove(Base.Policy[] storage cache, uint index) external returns(Base.Policy memory) {
        uint cacheLength = cache.length;
        Base.Policy memory removedPolicy = cache[index];

        for(uint i = index; i < cacheLength - 1; i++) {
                cache[i] = cache[i+1];
            }
        cache.pop();
        return removedPolicy;
    }

    function check(CacheList storage cache, Base.SubjectAttribute calldata sa, Base.ObjectAttribute calldata oa) external view returns(int) {
        int index = -1;
        uint cacheLength = cache.buffer.length;
        require(cacheLength > 0);

        uint startLocation = cache.start;

        for(int i = int(startLocation); i >= 0; i--) {
            if(keccak256(abi.encodePacked(sa.name)) != keccak256(abi.encodePacked(cache.buffer[uint(i)].subject.attribute.name))) {
                continue;
            }
            if(keccak256(abi.encodePacked(sa.role)) != keccak256(abi.encodePacked(cache.buffer[uint(i)].subject.attribute.role))) {
                continue;
            }
            if(keccak256(abi.encodePacked(oa.name)) != keccak256(abi.encodePacked(cache.buffer[uint(i)].object.attribute.name))) {
                continue;
            }
            if(keccak256(abi.encodePacked(oa.place)) != keccak256(abi.encodePacked(cache.buffer[uint(i)].object.attribute.place))) {
                continue;
            }
            index = i;
            return index;
        }

        for(int j = int(cacheLength - 1); j > int(startLocation); j--) {
            if(keccak256(abi.encodePacked(sa.name)) != keccak256(abi.encodePacked(cache.buffer[uint(j)].subject.attribute.name))) {
                continue;
            }
            if(keccak256(abi.encodePacked(sa.role)) != keccak256(abi.encodePacked(cache.buffer[uint(j)].subject.attribute.role))) {
                continue;
            }
            if(keccak256(abi.encodePacked(oa.name)) != keccak256(abi.encodePacked(cache.buffer[uint(j)].object.attribute.name))) {
                continue;
            }
            if(keccak256(abi.encodePacked(oa.place)) != keccak256(abi.encodePacked(cache.buffer[uint(j)].object.attribute.place))) {
                continue;
            }
            index = j;
            return index;
        }

        return index;
    }
}
