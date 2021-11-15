// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract CourseMarketplace {
    enum State {
        Purchased,
        Activated,
        Deactivated
    }

    struct Course {
        uint256 id; // 32
        uint256 price; // 32
        bytes32 proof; // 32
        address owner; // 20
        State state; // 1
    }

    // mapping of courseHash to Course data
    mapping(bytes32 => Course) private ownedCourses;

    // mapping of coueseID to courseHash
    mapping(uint256 => bytes32) private ownedCoursesHash;

    // the number of all courses + id of the course
    uint256 private totalOwnedCourses;

    address payable private owner;

    constructor() {
        setContractOwner(msg.sender);
    }

    /// Course has already a Owner!
    error CourseHasOwner();

    /// Only owner has an access!
    error OnlyOwner();

    modifier onlyOwner() {
      if (msg.sender != getContractOwner()) {
        revert OnlyOwner();
      }

      _;
    }

    function purchaseCourse(bytes16 courseId, bytes32 proof) external payable {
        // course id - 10
        // course id = 3130 (hexadecimal)
        // 0x00000000000000000000000000003130

        // 000000000000000000000000000031305B38Da6a701c568545dCfcB03FcB875f56beddC4
        // keccak256 - c4eaa3558504e2baa2669001b43f359b8418b44a4477ff417b4b007d7cc86e37
        // 0xc4eaa3558504e2baa2669001b43f359b8418b44a4477ff417b4b007d7cc86e37
        bytes32 courseHash = keccak256(abi.encodePacked(courseId, msg.sender));

        if (hasCourseOwnership(courseHash)) {
            revert CourseHasOwner();
        }

        uint256 id = totalOwnedCourses++;

        ownedCoursesHash[id] = courseHash;
        ownedCourses[courseHash] = Course({
            id: id,
            price: msg.value,
            proof: proof,
            state: State.Purchased,
            owner: msg.sender
        });
    }

    function getCourseCount() external view returns (uint256) {
        return totalOwnedCourses;
    }

    function getCourseHashAtIndex(uint256 index)
        external
        view
        returns (bytes32)
    {
        return ownedCoursesHash[index];
    }

    function getCourseByHash(bytes32 courseHash)
        external
        view
        returns (Course memory)
    {
        return ownedCourses[courseHash];
    }

    function getContractOwner() public view returns (address) {
        return owner;
    }

    function setContractOwner(address newOwner) private {
        owner = payable(newOwner);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        setContractOwner(newOwner);
    }

    function hasCourseOwnership(bytes32 courseHash)
        private
        view
        returns (bool)
    {
        return ownedCourses[courseHash].owner == msg.sender;
    }
}
