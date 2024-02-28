// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Base{
    struct ObjectAttribute {
        string name;
        string place;
    }

    struct Object {
        string id;
        ObjectAttribute attribute;
    }

    struct SubjectAttribute {
        string name;
        string role;
    }

    struct Subject {
        string id;
        SubjectAttribute attribute;
    }

    struct Action {
        bool write;
        bool read;
        bool execute;
    }

    struct Context {
        uint start;
        uint end;
    }

    struct Policy {
        Subject subject;
        Object object;
        Action action;
        Context context;
    }
}