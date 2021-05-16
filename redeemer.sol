pragma solidity 0.8.0;

import './YOLAPtoken.sol';

contract redeemer {
    
    constructor() public {
        msg.sender = owner;
    }
    
    uint public price;
    IERC0 public YOLAP = IERC20();
    
    function setPrice(uint _newPriceInWei) public {
        require(msg.sender == owner);
        price = _newPriceInWei;
    }

    function buyMembership(address _to) external {
        require(YOLAP.transferFrom(msg.sender, _to, price, "NakedApes: Must increase contracts token allowance"));
        
        // TODO: SEND USER THE MEMBERSHIP TOKEN THEY JUST BOUGHT
        
        
    }    
}
