// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title EnhancedSafeMathTester
 * @dev Demonstrates secure usage of Solidity's unchecked block for gas optimization
 * @notice This contract implements multiple security patterns for unchecked arithmetic
 */
contract EnhancedSafeMathTester {
    /**
     * @dev Variable intentionally initialized near its max value (255) to demonstrate overflow protection
     * @notice uint8 can only store values from 0-255
     */
    uint8 public bigNumber = 225;
    
    /**
     * @dev Emergency stop for circuit breaker pattern
     */
    bool public emergencyStop = false;
    
    /**
     * @dev Owner address for access control
     */
    address public owner;
    
    /**
     * @dev Events for monitoring arithmetic operations
     */
    event ValueChanged(uint8 oldValue, uint8 newValue, string operation);
    event EmergencyToggled(bool stopped);
    
    /**
     * @dev Constructor sets the contract deployer as owner
     */
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev Modifier to restrict functions to owner only
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }
    
    /**
     * @dev Modifier to check if emergency stop is active
     */
    modifier whenNotStopped() {
        require(!emergencyStop, "Contract is paused");
        _;
    }

    /**
     * @dev Basic unchecked increment with no safety features
     * @notice UNSAFE - included only for demonstration purposes
     */
    function unsafeAdd() public whenNotStopped {
        uint8 oldValue = bigNumber;
        
        unchecked { 
            bigNumber += 1;
        }
        
        emit ValueChanged(oldValue, bigNumber, "unsafeAdd");
    }
    
    /**
     * @dev Manual overflow check before unchecked operation
     * @param x The amount to add to bigNumber
     */
    function safeAdd(uint8 x) public whenNotStopped {
        // Manual check before performing unchecked operation
        require(bigNumber <= 255 - x, "Addition would overflow");
        
        uint8 oldValue = bigNumber;
        
        unchecked {
            bigNumber += x;
        }
        
        emit ValueChanged(oldValue, bigNumber, "safeAdd");
    }
    
    /**
     * @dev Bounded operation that prevents overflow
     */
    function boundedIncrement() public whenNotStopped {
        uint8 oldValue = bigNumber;
        
        unchecked {
            // Ensure value stays within bounds
            if (bigNumber < 255) {
                bigNumber += 1;
            }
        }
        
        emit ValueChanged(oldValue, bigNumber, "boundedIncrement");
    }
    
    /**
     * @dev Toggle the emergency stop
     * @notice Only callable by the contract owner
     */
    function toggleEmergencyStop() public onlyOwner {
        emergencyStop = !emergencyStop;
        emit EmergencyToggled(emergencyStop);
    }
    
    /**
     * @dev Set a new value with range validation
     * @param newValue The new value to set
     */
    function setBigNumber(uint8 newValue) public onlyOwner whenNotStopped {
        uint8 oldValue = bigNumber;
        bigNumber = newValue;
        emit ValueChanged(oldValue, bigNumber, "setBigNumber");
    }
    
    /**
     * @dev Get the current value and how far it is from overflowing
     * @return The current value of bigNumber
     * @return Distance from maximum value (255)
     */
    function getBigNumberStats() public view returns (uint8, uint8) {
        return (bigNumber, type(uint8).max - bigNumber);
    }
    
    /**
     * @dev Mathematical bounds validation before operation
     */
    function doubleIfSafe() public whenNotStopped {
        // Ensure doubling won't overflow
        require(bigNumber <= 127, "Doubling would overflow");
        
        uint8 oldValue = bigNumber;
        
        unchecked {
            bigNumber *= 2;
        }
        
        emit ValueChanged(oldValue, bigNumber, "doubleIfSafe");
    }
    
    /**
     * @dev Alternative implementation with standard checked arithmetic
     * @notice This will revert automatically if overflow would occur
     */
    function addWithCheck() public whenNotStopped {
        uint8 oldValue = bigNumber;
        
        // This will revert if bigNumber = 255
        bigNumber += 1;
        
        emit ValueChanged(oldValue, bigNumber, "addWithCheck");
    }
    
    /**
     * @dev Get the maximum possible value for reference
     */
    function getMaxValue() public pure returns (uint8) {
        return type(uint8).max; // Returns 255 for uint8
    }
}