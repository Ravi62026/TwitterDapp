// SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 < 0.9.0;

contract Twitter {

    // address of owner of account

    address public owner ;  

    // struct for tweet

    struct Tweet {
        uint id ;
        address author ;  // from -> who tweets
        string content ;
        uint createdAt;
    }

    // struct for message 

    struct message {
        uint id ;
        string content ;
        address from ;
        address to ;
        uint createdAt ;
    }

    // mapping 

    mapping (uint => Tweet) public tweets ;
    mapping (address => uint[]) public tweetsOf ;
    mapping (address => message[]) public messages ;
    mapping (address => mapping (address => bool)) public operators ;
    mapping (address => address[]) public followings ;

    // event to create tweet

    event TweetCreated(uint indexed tweetId, address indexed author, string content, uint createdAt);

    // event to create message

    event MessageSent(uint indexed messageId, address indexed from, address indexed to, string content, uint createdAt);

    // variable to track

    uint public nextID ;  // tweet count
    uint public nextMessageId;  // message count

    // modifier for only owner can call the function

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyOperator(address _operator) {
        require(operators[msg.sender][_operator], "Not authorized operator");
        _;
    }

    modifier tweetContentNotEmpty(string memory _content) {
        require(bytes(_content).length > 0, "Tweet content cannot be empty");
        _;
    }

    modifier messageContentNotEmpty(string memory _content) {
        require(bytes(_content).length > 0, "Message content cannot be empty");
        _;
    }

    // function to create tweet

    function _tweet(address _from, string memory _content) internal tweetContentNotEmpty(_content) {
        tweets[nextID] = Tweet(nextID, _from, _content, block.timestamp);
        tweetsOf[_from].push(nextID);
        emit TweetCreated(nextID, _from, _content, block.timestamp);
        nextID++;
    }

    // function to send message

    function _sendMessage(address _from , address _to , string memory _content) internal  {
        messages[_from].push(message(nextMessageId , _content , _from , _to , block.timestamp));
        nextMessageId = nextMessageId + 1;
    }

    // function _sendMessage(address _from, address _to, string memory _content) internal messageContentNotEmpty(_content) {
    //     messages[_from].push(message(nextMessageId, _content, _from, _to, block.timestamp));
    //     emit MessageSent(nextMessageId, _from, _to, _content, block.timestamp);
    //     nextMessageId++;
    // }

    // tweet by owner of account

    function tweet(string memory _content) public {
        _tweet(msg.sender, _content);
    }


    // tweet by someone on behalf of owner -> pr team 

    function tweet(address _from ,string memory _content) public {
        _tweet(_from, _content);
    }

    // message by owner

    function sendMessage(address _to , string memory _content) public {
        _sendMessage(msg.sender, _to, _content);
    }

    // message by someone on behalf of owner -> pr team

    function sendMessage(address _from , address _to , string memory _content) public {
        _sendMessage(_from, _to, _content);
    }

    // function to follow someone 

    function follow(address _followed) public {
        followings[msg.sender].push(_followed);
    }

    // function to allow access my account to some one

    function allow(address _operator) public {
        operators[msg.sender][_operator] = true ;
    }

    // function to not allow access my account to some one

    function disallow(address _operator) public {
        operators[msg.sender][_operator] = true ;
    }

    // function to get latest tweet

    function getLaestTweets(uint count) public view returns(Tweet[] memory){
        require(count > 0 && count <= nextID , "Count is not valid");

        // Empty array of type Tweet with lngth equal to count 

        Tweet[] memory _tweets = new Tweet[](count) ;

        uint j;

        for(uint i = nextID - count ; i < nextID ; i++) {
            Tweet storage _structure = tweets[i] ;
            _tweets[j] = Tweet(_structure.id , _structure.author , _structure.content , _structure.createdAt) ;
            j = j + 1 ;
        }

        return _tweets ;
    }

    function getLaestTweetOfUser(address _user , uint count) public view returns(Tweet[] memory){

        require(count > 0 && count <= nextID , "Count not exists") ;

        Tweet[] memory _tweets = new Tweet[](count) ;

        uint[] memory ids = tweetsOf[_user] ;

        uint len = ids.length;

        uint j;

        for(uint i = len - count ; i < len ; i++) {
            Tweet storage _structure = tweets[ids[i]] ;
            _tweets[j] = Tweet(_structure.id , _structure.author , _structure.content , _structure.createdAt) ;
            j = j + 1 ;
        }

        return _tweets ;

    }

}
