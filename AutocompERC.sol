// File: contracts\lib\SafeMath.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction underflow");
    }

 
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function mul(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, errorMessage);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts\lib\IERC20.sol


pragma solidity ^0.7.0;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts\lib\ERC20.sol

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

abstract contract ERC20 {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    uint256 public totalSupply;



    mapping (address => mapping (address => uint256)) internal allowances;
    mapping (address => uint256) internal balances;

    /// keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")
    bytes32 public constant DOMAIN_TYPEHASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    /// keccak256("1");
    bytes32 public constant VERSION_HASH = 0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6;

    /// keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    mapping(address => uint) public nonces;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {

    }

    function allowance(address account, address spender) external view returns (uint) {
        return allowances[account][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function balanceOf(address account) external view returns (uint) {
        return balances[account];
    }

    function transfer(address dst, uint256 amount) external returns (bool) {
        _transferTokens(msg.sender, dst, amount);
        return true;
    }

    function transferFrom(address src, address dst, uint256 amount) external returns (bool) {
        address spender = msg.sender;
        uint256 spenderAllowance = allowances[src][spender];

        if (spender != src && spenderAllowance != uint256(-1)) {
            uint256 newAllowance = spenderAllowance.sub(amount, "transferFrom: transfer amount exceeds allowance");
            allowances[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        _transferTokens(src, dst, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "_approve::owner zero address");
        require(spender != address(0), "_approve::spender zero address");
        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transferTokens(address from, address to, uint256 value) internal {
        require(to != address(0), "_transferTokens: cannot transfer to the zero address");

        balances[from] = balances[from].sub(value, "_transferTokens: transfer exceeds from balance");
        balances[to] = balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address to, uint256 value) internal {
        totalSupply = totalSupply.add(value);
        balances[to] = balances[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {
        balances[from] = balances[from].sub(value, "_burn: burn amount exceeds from balance");
        totalSupply = totalSupply.sub(value, "_burn: burn amount exceeds total supply");
        emit Transfer(from, address(0), value);
    }

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        require(deadline >= block.timestamp, "permit::expired");

        bytes32 encodeData = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline));
        _validateSignedData(owner, encodeData, v, r, s);

        _approve(owner, spender, value);
    }

    function _validateSignedData(address signer, bytes32 encodeData, uint8 v, bytes32 r, bytes32 s) internal view {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                getDomainSeparator(),
                encodeData
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        // Explicitly disallow authorizations for address(0) as ecrecover returns address(0) on malformed messages
        require(recoveredAddress != address(0) && recoveredAddress == signer, "Arch::validateSig: invalid signature");
    }

    function getDomainSeparator() public view returns (bytes32) {
        return keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name)),
                VERSION_HASH,
                _getChainId(),
                address(this)
            )
        );
    }

    function _getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}

// File: contracts\lib\IChef.sol


pragma solidity ^0.7.0;

interface IChef {
    function poolLength() external view returns (uint256);
    function add(uint256 _allocPoint, address _lpToken, bool _withUpdate) external;
    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) external;
    function getMultiplier(uint256 _from, uint256 _to) external view returns (uint256);
    function pendingCake(uint256 _pid, address _member) external view returns (uint256);
    function massUpdatePools() external;
    function updatePool(uint256 _pid) external;
    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
    function emergencyWithdraw(uint256 _pid) external;
    function dev(address _devaddr) external;
    event Deposit(address indexed member, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed member, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed member, uint256 indexed pid, uint256 amount);
}

// File: contracts\lib\IRouter.sol


pragma solidity ^0.7.0;

interface IRouter {
    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountToken, uint amountETH);
    function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountETH);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens( uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] memory path) external view returns (uint[] memory amounts);
}

// File: contracts\lib\IPair.sol


pragma solidity ^0.7.0;

interface IPair is IERC20 {
    function token0() external pure returns (address);
    function token1() external pure returns (address);
}


// File: contracts\ChefLPforLP.sol

pragma solidity ^0.7.0;

contract CHEF_LP_FOR_LP is ERC20, Ownable {
    using SafeMath for uint;

    uint public totalDeposits;

    IRouter public router;
    IPair public LPtoken;
    IERC20 private token0;
    IERC20 private token1;
    IERC20 public rewardToken;
    IChef public Chef;
    uint256 public PID;
    address public owner;

    event Deposit(address account, uint amount);
    event Withdraw(address account, uint amount);
    event Reinvest(uint newTotalDeposits, uint newTotalSupply);

    constructor(
        address _LPtoken,
        address _rewardToken,
        address _Chef,
        address _router,
        uint _pid,
        string memory _name,
        string memory _symbol,
        address _owner
    ) {
        owner = _owner;
        name = _name;
        symbol = _symbol;
        LPtoken = IPair(_LPtoken);
        rewardToken = IERC20(_rewardToken);
        Chef = IChef(_Chef);
        router = IRouter(_router);
        PID = _pid;
        address _token0 = IPair(_LPtoken).token0();
        address _token1 = IPair(_LPtoken).token1();
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);

        // approve all needed contracts for spending
        IERC20(_rewardToken).approve(_router, uint(-1));
        IERC20(_token0).approve(_router, uint(-1));
        IERC20(_token1).approve(_router, uint(-1));
        IPair(_LPtoken).approve(_Chef, uint(-1));
    }

    mapping(address => bool) public members;

    modifier onlyOwner() {
        require(msg.sender == owner, "NakedApes: caller is not the owner");
        _;
    }

    modifier onlyEOA() {
        require(tx.origin == msg.sender, "NakedApes: onlyEOA (only externally owned account)");
        _;
    }

    function addmember(address _member) public onlyOwner {
        members[_member] = true;
    }

    function removemember(address _member) public onlyOwner {
        members[_member] = false;
    }

    function DEPOSIT(uint amount) external {
        _DEPOSIT(amount);
    }

    function _DEPOSIT(uint amount) internal {
        require(members[msg.sender], "NakedApes: you're not on whitelist");
        require(totalDeposits >= totalSupply, "NakedApes: DEPOSIT failed");
        require(LPtoken.transferFrom(msg.sender, address(this), amount), "NakedApes: transferFrom failed");
        _DEPOSIT_INTO_CHEF(amount);
        _mint(msg.sender, GET_SHARES_PER_LP(amount));
        totalDeposits = totalDeposits.add(amount);
        emit Deposit(msg.sender, amount);
    }

    function WITHDRAW(uint amount) external {
        uint LPtokenAmount = GET_LP_TOKENS_PER_SHARE(amount);
        if (LPtokenAmount > 0) {
        _WITHDRAW_FROM_CHEF(LPtokenAmount);
        require(LPtoken.transfer(msg.sender, LPtokenAmount), "transfer failed");
        _burn(msg.sender, amount);
        totalDeposits = totalDeposits.sub(LPtokenAmount);
        emit Withdraw(msg.sender, LPtokenAmount);
        }
    }

    function CHECK_POOL_EARNINGS() public view returns (uint) {
        uint pendingReward = Chef.pendingCake(PID, address(this));
        uint contractBalance = rewardToken.balanceOf(address(this));
        return pendingReward.add(contractBalance);
    }

    function REINVEST() external onlyEOA {
        uint unclaimedRewards = CHECK_POOL_EARNINGS();
        Chef.deposit(PID, 0);
        uint LPtokenAmount = _CONVERT_EARNINGS_TO_MORE_LP(unclaimedRewards);
        _DEPOSIT_INTO_CHEF(LPtokenAmount);
        totalDeposits = totalDeposits.add(LPtokenAmount);
        emit Reinvest(totalDeposits, totalSupply);
    }

    function _CONVERT_EARNINGS_TO_MORE_LP(uint amount) internal returns (uint) {
        uint amountIn = amount.div(2);
        require(amountIn > 0, "amount too low");

        // swap to token0
        address[] memory path0 = new address[](2);
        path0[0] = address(rewardToken);
        path0[1] = address(token0);

        uint amountOutToken0 = amountIn;
        if (path0[0] != path0[1]) {
        uint[] memory amountsOutToken0 = router.getAmountsOut(amountIn, path0);
        amountOutToken0 = amountsOutToken0[amountsOutToken0.length - 1];
        router.swapExactTokensForTokens(amountIn, amountOutToken0, path0, address(this), block.timestamp);
        }

        // swap to token1
        address[] memory path1 = new address[](2);
        path1[0] = path0[0];
        path1[1] = address(token1);

        uint amountOutToken1 = amountIn;
        if (path1[0] != path1[1]) {
        uint[] memory amountsOutToken1 = router.getAmountsOut(amountIn, path1);
        amountOutToken1 = amountsOutToken1[amountsOutToken1.length - 1];
        router.swapExactTokensForTokens(amountIn, amountOutToken1, path1, address(this), block.timestamp);
        }

        (,,uint liquidity) = router.addLiquidity(
        path0[1], path1[1],
        amountOutToken0, amountOutToken1,
        0, 0,
        address(this),
        block.timestamp
        );

        return liquidity;
    }
        

    function _DEPOSIT_INTO_CHEF(uint amount) internal {
        require(amount > 0, "amount too low");
        Chef.deposit(PID, amount);
    }

    function _WITHDRAW_FROM_CHEF(uint amount) internal {
        require(amount > 0, "amount too low");
        Chef.withdraw(PID, amount);
    }

    function GET_SHARES_PER_LP(uint amount) public view returns (uint) {
        if (totalSupply.mul(totalDeposits) == 0) {
        return amount;
        }
        return amount.mul(totalSupply.div(totalDeposits));
    }

    function GET_LP_TOKENS_PER_SHARE(uint amount) public view returns (uint) {
        if (totalSupply.mul(totalDeposits) == 0) {
        return 0;
        }
        return amount.mul(totalDeposits).div(totalSupply);
    }
}
