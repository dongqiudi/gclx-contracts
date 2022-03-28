// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "erc721a/contracts/ERC721A.sol";

contract LHHS is ERC721A, Ownable {
    enum Status {
        Waiting,
        Started,
        Finished
    }

    Status public status;
    string public baseURI;
    uint256 public constant MAX_MINT_PER_ADDR = 2;
    uint256 public constant MAX_SUPPLY = 6666;
    uint256 public constant PRICE = 0.0066 * 10**18; // 0.0066 ETH

    event Minted(address minter, uint256 amount);
    event StatusChanged(Status status);
    event BaseURIChanged(string newBaseURI);

    constructor(string memory initBaseURI) ERC721A("LHHSNFT", "LHHS") {
        baseURI = initBaseURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function mint(uint256 quantity) external payable {
        require(status == Status.Started, "LHHS: Hai mei kai shi.");
        require(tx.origin == msg.sender, "LHHS: Bu yun xu he yue diao yong.");
        require(
            numberMinted(msg.sender) + quantity <= MAX_MINT_PER_ADDR,
            "LHHS: Zui duo lia."
        );
        require(
            totalSupply() + quantity <= MAX_SUPPLY,
            "LHHS: Mei zhe me duo le."
        );

        _safeMint(msg.sender, quantity);
        refundIfOver(PRICE * quantity);

        emit Minted(msg.sender, quantity);
    }

    function numberMinted(address owner) public view returns (uint256) {
        return _numberMinted(owner);
    }

    function refundIfOver(uint256 price) private {
        require(msg.value >= price, "LHHS: Mei duo gei ETH.");
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }

    function setStatus(Status _status) external onlyOwner {
        status = _status;
        emit StatusChanged(status);
    }

    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        baseURI = newBaseURI;
        emit BaseURIChanged(newBaseURI);
    }

    function withdraw(address payable recipient) external onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = recipient.call{value: balance}("");
        require(success, "LHHS: Wan le, quan wan le.");
    }
}
