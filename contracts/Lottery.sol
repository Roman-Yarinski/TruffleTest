pragma solidity >=0.5.0 <0.6.0;

import "./ownable.sol";
import "./safemath.sol";

/** 
 * @title Block-chain Lottery
 * @author Roman Yarinki [299442676t@gmail.com]
 */
contract Lottery is Ownable {

    using SafeMath for uint256;
    
    event BuyTicket(address addr, uint256 time, uint256 transf);
    event LotteryDraw(address winer, uint payoff);
    event LotteryRestarted(uint256 upToTime);
    
    // State of lottery
    bool private _lotteryIsActive = true;                                                              
    
    // The lottery is open until then
    uint256 private _upToTime;
    // Ticket price
    uint256 private _ticketPrise = 0.2 ether;
    // Max players in this lottery
    uint256 private _maxPlayers = 10;
    // How long will the lottery run
    uint256 private _lotteryDuration = 1 weeks;
    
    // Last winner
    address private _lastWinner;
    
    struct Member {
        address addr;   // Address of member
        uint256 time;   // The time of ticket buying
        uint256 transf; // Tranfer value
    }
    
    // Array of members
    Member [] private _members;
    // Array address of members
    address [] private _adressOfMembers;  
    
    /**
     * @dev Set the start time of the lottery.
     */
    constructor() public {        
        _upToTime = block.timestamp.add(_lotteryDuration);
    }
    
    /**
     * @dev Buying lottery tickets.
     * @return A boolean value indicating whether the operation succeeded.
     */
    function buy() payable public returns(bool) {
        require(_lotteryIsActive == true, "Lottery: lottery is not active, you can't Buy");
        
        if(block.timestamp > _upToTime) {
          offLottery();
          return false;
        }
        
        if(msg.value < _ticketPrise) return false;
        
        _members.push(Member(msg.sender, block.timestamp, msg.value));
        _adressOfMembers.push(msg.sender);
        
        if(_members.length == _maxPlayers) offLottery();
        
        emit BuyTicket( msg.sender, block.timestamp, msg.value);
        return true;
    }
    
    /**
     * @dev Determines the winner from the array of members.
     * @return Random number from 0 to number of members.
     */
    function findWinner() view internal returns( uint256 ) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, _members.length))) % _members.length;
    }
    
    /**
     * @dev Draws a lottery ,pays out the winnings, and sends the balance to the owner.
     * return A boolean value indicating whether the operation succeeded.
     */
    function pay() public onlyOwner returns(bool) {
        require(_lotteryIsActive == false, "Lottery: lottery is active, you can't Pay");
          
        uint256 winnerId = findWinner();
        
        address payable winner = address(uint256(_members[winnerId].addr));
        address payable owner = address(uint256(owner()));
        
        _lastWinner = winner;
        uint256 payoff = address(this).balance.div(2);
        
        winner.transfer(payoff); 
        owner.transfer(address(this).balance);
        
        emit LotteryDraw(winner, payoff);
        return true;
    }
    
    /**
     * @dev Restart lottery, delete all members, update the start time.
     * return A boolean value indicating whether the operation succeeded.
     */
    function restart() public onlyOwner returns(bool) {
        require(_lotteryIsActive == false);
        
        onLottery();
        _upToTime = block.timestamp.add(_lotteryDuration);
        _members.length = 0;
        
        emit LotteryRestarted(_upToTime);
        return true;
    }

    /**
     * @dev @dev Changes the state of lottery to false.
     * return A boolean value indicating whether the operation succeeded.
     */
    function offLottery() public onlyOwner returns(bool) {
        _lotteryIsActive = false;
        return true;
    }
    
    /**
     * @dev Changes the state of lottery to true.
     * return A boolean value indicating whether the operation succeeded.
     */
    function onLottery() public onlyOwner returns(bool) {
        _lotteryIsActive = true;
        return true;
    }
    
    /**
     * @dev Set max pleyers number.
     * param maxPlayers Maximum number of members in the lottery.
     * return A boolean value indicating whether the operation succeeded.
     */
    function setMaxPlayers(uint256 maxPlayers) public onlyOwner returns(bool){
        require(_members.length == 0);
        
        _maxPlayers = maxPlayers;
        return true;
    }
    
    /**
     * @dev Set lottery duration.
     * param lotteryDuration How long will the lottery run.
     * return A boolean value indicating whether the operation succeeded.
     */
    function setLotteryDuration(uint256 lotteryDuration) public onlyOwner returns(bool) {
        _lotteryDuration = lotteryDuration;
        return true;
    }
    
    /**
     * @dev Set ticket price.
     * param ticketPrise Ticket price.
     * return A boolean value indicating whether the operation succeeded.
     */
    function setTicketPrise(uint256 ticketPrise) public onlyOwner returns(bool) {
        _ticketPrise = ticketPrise;
        return true;
    }
    
    /**
     * @dev Get lottery state.
     * return A boolean value that indicates the state of the lottery.
     */
    function getLotteryIsActive() public view returns(bool) {
        return _lotteryIsActive;
    }
    
    /**
     * @dev Get lottery Duration.
     * return How long will the lottery run.
     */
     function getLotteryDuration() public view returns(uint256) {
        return _lotteryDuration;
    }
    
    /**
     * @dev Get up to time.
     * return Time will the lottery run until.
     */
    function getUpToTime() public view returns(uint256) {
        return _upToTime;
    }
    
    /**
     * @dev Get up to time.
     * return Time will the lottery run until.
     */
    function getMembersLength() public view returns(uint256) {
        return _members.length;
    }
    
    /**
     * @dev Get last winner.
     * return Address of last winner.
     */
    function getLastWiner() public view returns(address) {
        return _lastWinner;
    }
    
    /**
     * @dev Get ticket prise.
     * return Ticket prise .
     */
    function getTicketPrise() public view returns(uint256) {
        return _ticketPrise;
    }
    
    /**
     * @dev Get max number of members.
     * return Max number of members.
     */
    function getMaxPlayers() public view returns(uint256) {
        return _maxPlayers;
    }
    
    /**
     * @dev Get dress of members.
     * return Address array of members.
     */
    function getAdressOfMembers() public view returns(address[] memory) {
        return _adressOfMembers;
    }
    /**
     * @dev Get member from members.
     * @param id of member.
     * @return All about member from members by id.
     */
    function getMemberFromMembers( uint id) public view returns (address, uint256, uint256) {
        return(_members[id].addr, _members[id].time, _members[id].transf);
    }

}
