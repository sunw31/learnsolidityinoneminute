pragma solidity ^0.4.19;

import "./zombiefactory.sol";

// 没有函数体，即接口
contract KittyInterface {
  function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}

contract ZombieFeeding is ZombieFactory {

  // 从链上获取合约
  // onlyOwner修饰符限制了external为Ownable继承链下的合约才能调用
  KittyInterface kittyContract;
  function setKittyContractAddress(address _address) external onlyOwner{
    kittyContract = KittyInterface(_address);
  }

  // storage传引用而不是memory副本
  // now是uint256类型
  function _triggerCooldown(Zombie storage _zombie) internal {
    _zombie.readyTime = uint32(now + cooldownTime);
  }

  function _isReady(Zombie storage _zombie) internal view returns (bool) {
    return (_zombie.readyTime <= now);
  }

  // storage变量将存储在区块链上
  // memory变量只是临时副本修改 
  function feedAndMultiply(uint _zombieId, uint _targetDna, string species) internal {
    require(msg.sender == zombieToOwner[_zombieId]);
    Zombie storage myZombie = zombies[_zombieId];
    require(_isReady(myZombie));
    _targetDna = _targetDna % dnaModulus;
    uint newDna = (myZombie.dna + _targetDna) / 2;
    if (keccak256(species) == keccak256("kitty")) {
      // 取模10**2得到最后两位
      newDna = newDna - newDna % 100 + 99;
    }
    _createZombie("NoName", newDna);
     _triggerCooldown(myZombie);
  }

  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    uint kittyDna;
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
    // 并修改函数调用
    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }
}
