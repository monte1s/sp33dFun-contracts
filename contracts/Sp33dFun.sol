// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

import {Sp33dFunToken} from "./Sp33dFunToken.sol";
import {ISolidlyRouter} from "./interfaces/ISolidlyRouter.sol";
import {ISolidlyFactory} from "./interfaces/ISolidlyFactory.sol";

contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Sp33dFun is Ownable, PausableUpgradeable {
    using Address for address payable;

    struct Token {
        address instance;
        address owner;
        string name;
        string symbol;
        string uri;
        uint256 maxSupply;
    }

    address constant WETH = address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);
    ISolidlyRouter constant router =
        ISolidlyRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
    ISolidlyFactory constant factory =
        ISolidlyFactory(0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc);

    uint256 public initialAmount = 0.01 ether;

    Token[] internal tokens;
    mapping(address => uint256) public tokenIndexes;

    uint256 public MAX_SUPPLY = 1000000000 ether;

    error InvalidParams();
    error OwnershipTransferFailed();

    event Launched(
        address owner,
        string name,
        string symbol,
        string uri,
        uint256 maxSupply,
        address token
    );

    event HandleLiquidity(
        address owner,
        address token0,
        address token1,
        address pair
    );

    receive() external payable {}

    // token creator functions
    function launch(
        address tokenOwner,
        string memory name,
        string memory symbol,
        string memory uri
    ) external payable whenNotPaused {
        require(
            msg.value >= initialAmount,
            "InitialAmount: invalid initial Amount!"
        );

        Sp33dFunToken instance = new Sp33dFunToken();

        Sp33dFunToken(instance).initialize(
            name,
            symbol,
            uri,
            tokenOwner,
            MAX_SUPPLY,
            initialAmount
        );

        handleLiquidity(address(instance), tokenOwner);

        tokens.push(
            Token({
                instance: address(instance),
                owner: tokenOwner,
                name: name,
                symbol: symbol,
                uri: uri,
                maxSupply: MAX_SUPPLY
            })
        );

        tokenIndexes[address(instance)] = tokens.length - 1;

        emit Launched(
            tokenOwner,
            name,
            symbol,
            uri,
            MAX_SUPPLY,
            address(instance)
        );
    }

    function handleLiquidity(address _token, address _to) internal {
        address pair = factory.createPair(_token, WETH);
        uint256 tokenBalance = IERC20(_token).balanceOf(address(this));

        IERC20(_token).approve(address(router), tokenBalance);

        router.addLiquidityETH{value: initialAmount}(
            address(_token),
            tokenBalance,
            0,
            0,
            _to, // keep the LP tokens
            block.timestamp
        );

        emit HandleLiquidity(_to, WETH, _token, pair);
    }

    function launchPermissioned(address tokenOwner, address token)
        external
        onlyOwner
    {
        tokens.push(
            Token({
                instance: token,
                owner: tokenOwner,
                name: Sp33dFunToken(token).name(),
                symbol: Sp33dFunToken(token).symbol(),
                uri: Sp33dFunToken(token).uri(),
                maxSupply: Sp33dFunToken(token).totalSupply()
            })
        );

        tokenIndexes[token] = tokens.length - 1;

        emit Launched(
            tokenOwner,
            Sp33dFunToken(token).name(),
            Sp33dFunToken(token).symbol(),
            Sp33dFunToken(token).uri(),
            Sp33dFunToken(token).totalSupply(),
            token
        );
    }

    function transferTokenOwnership(uint256 id, address newOwner) external {
        if (id >= tokens.length) revert OwnershipTransferFailed();
        if (tokens[id].owner != msg.sender) revert OwnershipTransferFailed();
        Token storage token = tokens[id];
        token.owner = newOwner;
    }

    // admin functions

    function claimLaunchTaxes() external onlyOwner {
        payable(owner()).sendValue(address(this).balance);
    }

    function togglePause() external onlyOwner {
        if (paused()) _unpause();
        else _pause();
    }

    function updateMaxSupply(uint256 _maxSupply) external onlyOwner {
        MAX_SUPPLY = _maxSupply;
    }

    function updateInitialAmount(uint256 _initialAmount) external onlyOwner {
        initialAmount = _initialAmount;
    }

    // view functions

    function getToken(uint256 id) external view returns (Token memory) {
        if (id >= tokens.length)
            return Token(address(0), address(0), "", "", "", 0);
        return tokens[id];
    }

    function getAllToken() external view returns (Token[] memory) {
        return tokens;
    }

    function allPairsLength() external view returns (uint256) {
        return tokens.length;
    }
}
