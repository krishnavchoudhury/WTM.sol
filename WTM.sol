// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Website Traffic Monitor
 * @dev Smart contract to track and monitor website traffic data on-chain
 * @author Your Name
 */
contract WebsiteTrafficMonitor {
    
    // Struct to store traffic data for each website
    struct TrafficData {
        uint256 totalVisits;
        uint256 uniqueVisitors;
        uint256 lastVisitTimestamp;
        bool isActive;
        address owner;
    }
    
    // Mapping from website domain hash to traffic data
    mapping(bytes32 => TrafficData) public websites;
    
    // Mapping to track registered websites by owner
    mapping(address => bytes32[]) public ownerWebsites;
    
    // Events
    event WebsiteRegistered(bytes32 indexed websiteHash, address indexed owner, string domain);
    event TrafficUpdated(bytes32 indexed websiteHash, uint256 totalVisits, uint256 uniqueVisitors);
    event WebsiteStatusChanged(bytes32 indexed websiteHash, bool isActive);
    
    // Modifiers
    modifier onlyWebsiteOwner(bytes32 _websiteHash) {
        require(websites[_websiteHash].owner == msg.sender, "Not website owner");
        _;
    }
    
    modifier websiteExists(bytes32 _websiteHash) {
        require(websites[_websiteHash].owner != address(0), "Website not registered");
        _;
    }
    
    /**
     * @dev Register a new website for traffic monitoring
     * @param _domain The domain name of the website
     */
    function registerWebsite(string memory _domain) external {
        bytes32 websiteHash = keccak256(abi.encodePacked(_domain));
        require(websites[websiteHash].owner == address(0), "Website already registered");
        
        websites[websiteHash] = TrafficData({
            totalVisits: 0,
            uniqueVisitors: 0,
            lastVisitTimestamp: block.timestamp,
            isActive: true,
            owner: msg.sender
        });
        
        ownerWebsites[msg.sender].push(websiteHash);
        
        emit WebsiteRegistered(websiteHash, msg.sender, _domain);
    }
    
    /**
     * @dev Update traffic data for a registered website
     * @param _websiteHash Hash of the website domain
     * @param _visits New total visit count
     * @param _uniqueVisitors New unique visitor count
     */
    function updateTraffic(
        bytes32 _websiteHash, 
        uint256 _visits, 
        uint256 _uniqueVisitors
    ) external onlyWebsiteOwner(_websiteHash) websiteExists(_websiteHash) {
        require(websites[_websiteHash].isActive, "Website monitoring is disabled");
        require(_visits >= websites[_websiteHash].totalVisits, "Visit count cannot decrease");
        require(_uniqueVisitors >= websites[_websiteHash].uniqueVisitors, "Unique visitor count cannot decrease");
        
        websites[_websiteHash].totalVisits = _visits;
        websites[_websiteHash].uniqueVisitors = _uniqueVisitors;
        websites[_websiteHash].lastVisitTimestamp = block.timestamp;
        
        emit TrafficUpdated(_websiteHash, _visits, _uniqueVisitors);
    }
    
    /**
     * @dev Get traffic data for a specific website
     * @param _websiteHash Hash of the website domain
     * @return totalVisits Total number of visits
     * @return uniqueVisitors Number of unique visitors
     * @return lastVisitTimestamp Timestamp of last update
     * @return isActive Whether monitoring is active
     * @return owner Address of the website owner
     */
    function getTrafficData(bytes32 _websiteHash) 
        external 
        view 
        websiteExists(_websiteHash) 
        returns (
            uint256 totalVisits,
            uint256 uniqueVisitors,
            uint256 lastVisitTimestamp,
            bool isActive,
            address owner
        ) 
    {
        TrafficData memory data = websites[_websiteHash];
        return (
            data.totalVisits,
            data.uniqueVisitors,
            data.lastVisitTimestamp,
            data.isActive,
            data.owner
        );
    }
    
    /**
     * @dev Toggle website monitoring status (active/inactive)
     * @param _websiteHash Hash of the website domain
     */
    function toggleWebsiteStatus(bytes32 _websiteHash) 
        external 
        onlyWebsiteOwner(_websiteHash) 
        websiteExists(_websiteHash) 
    {
        websites[_websiteHash].isActive = !websites[_websiteHash].isActive;
        emit WebsiteStatusChanged(_websiteHash, websites[_websiteHash].isActive);
    }
    
    /**
     * @dev Get all websites registered by a specific owner
     * @param _owner Address of the website owner
     * @return Array of website hashes owned by the address
     */
    function getOwnerWebsites(address _owner) external view returns (bytes32[] memory) {
        return ownerWebsites[_owner];
    }
    
    /**
     * @dev Generate website hash from domain string
     * @param _domain The domain name
     * @return The keccak256 hash of the domain
     */
    function generateWebsiteHash(string memory _domain) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(_domain));
    }
}
