pragma solidity ^0.4.23;

contract Bank {
	// 此合約的擁有者
    address private owner;

	// 儲存所有會員的餘額
    mapping (address => uint256) private balance;
    
    
    /* 紀錄每個帳戶定存資訊 */
    
    mapping (address => uint256) private CDAmount;
    mapping (address => uint256) private CDperiod;
    mapping (address => uint256) private CDinterest;

    /* 事件們，用於通知前端 web3.js */

    event CDEvent(address indexed from, uint256 value, uint256 period, uint256 timestamp);
    event CDFinishEvent(address indexed from, uint256 timestamp);
    event CDCancelEvent(address indexed from, uint256 period, uint256 timestamp);


	// 事件們，用於通知前端 web3.js
    event DepositEvent(address indexed from, uint256 value, uint256 timestamp);
    event WithdrawEvent(address indexed from, uint256 value, uint256 timestamp);
    event TransferEvent(address indexed from, address indexed to, uint256 value, uint256 timestamp);

    modifier isOwner() {
        require(owner == msg.sender, "you are not owner");
        _;
    }
    
	// 建構子
    constructor() public payable {
        owner = msg.sender;
    }

	// 存錢
    function deposit() public payable {
        balance[msg.sender] += msg.value;

        emit DepositEvent(msg.sender, msg.value, now);
    }

	// 提錢
    function withdraw(uint256 etherValue) public {
        uint256 weiValue = etherValue * 1 ether;

        require(balance[msg.sender] >= weiValue, "your balances are not enough");

        msg.sender.transfer(weiValue);

        balance[msg.sender] -= weiValue;

        emit WithdrawEvent(msg.sender, etherValue, now);
    }

	// 轉帳
    function transfer(address to, uint256 etherValue) public {
        uint256 weiValue = etherValue * 1 ether;

        require(balance[msg.sender] >= weiValue, "your balances are not enough");

        balance[msg.sender] -= weiValue;
        balance[to] += weiValue;

        emit TransferEvent(msg.sender, to, etherValue, now);
    }

	// 檢查銀行帳戶餘額
    function getBankBalance() public view returns (uint256) {
        return balance[msg.sender];
    }

    function kill() public isOwner {
        selfdestruct(owner);
    }
    
    /* 購買定存 */
    function CD(uint256 etherValue, uint256 period) public {
        
        uint256 weiValue = etherValue * 1 ether;

        require(balance[msg.sender] >= weiValue, "your balances are not enough");
        require(CDAmount[msg.sender] == 0, "Already have CD");
        require(CDperiod[msg.sender] == 0, "Already have CD");


        balance[msg.sender] -= weiValue;
        CDAmount[msg.sender] += weiValue;
        CDperiod[msg.sender] += period;

        emit CDEvent(msg.sender, etherValue, period, now);
    }

    /* 定存期滿 */
    function CDFinish() public {
        require(CDAmount[msg.sender] > 0, "you don't have CD");
        require(CDperiod[msg.sender] > 0, "you don't have CD");
        
        CDinterest[msg.sender] += CDAmount[msg.sender]/100*CDperiod[msg.sender];
        balance[msg.sender] += CDAmount[msg.sender];
        CDAmount[msg.sender] = 0;
        CDperiod[msg.sender] = 0;

        emit CDFinishEvent(msg.sender, now);
    }
    
    /* 提前解約 */
    function CDCancel(uint256 period) public {
        require(CDAmount[msg.sender] > 0, "you don't have CD");
        require(CDperiod[msg.sender] > 0, "you don't have CD");
        require(CDperiod[msg.sender] > period, "CD period less than input value");
        
        CDinterest[msg.sender] += CDAmount[msg.sender]/100*period;
        balance[msg.sender] += CDAmount[msg.sender];
        CDAmount[msg.sender] = 0;
        CDperiod[msg.sender] = 0;

        emit CDCancelEvent(msg.sender, period, now);
    }
    
    /* getter */
    
    function getBankCDAmount() public view returns (uint256) {
        return CDAmount[msg.sender];
    }
    
    function getBankCDPeriod() public view returns (uint256) {
        return CDperiod[msg.sender];
    }
    
    function getBankCDInterest() public view returns (uint256) {
        return CDinterest[msg.sender];
    }
    
    
}