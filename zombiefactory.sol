pragma solidity ^0.4.19;

import "./ownable.sol";

contract ZombieFactory is Ownable {

    // 不在struct声明的类型，uintX等价uint256的空间，不会节省gas
    // 控制DNA位数为16位，具体为数学取模
    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    uint cooldownTime = 1 days;


    struct Zombie {
        string name;
        uint dna;
    // 把同类型的，顺序放一起会节省Gas
        uint32 level;
        uint32 readyTime;
        uint16 winCount;
        uint16 lossCount;
    }

    // public修饰符 让zombies拥有getter方法但没有setter方法
    Zombie[] public zombies;

    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerZombieCount;

    // 前端监控合约事件
    // ZombieFactory.NewZombie(function(error, result) {})
    event NewZombie(uint zombieId, string name, uint dna);

    // _约定本地局部变量
    // 没有访问修饰的函数默认是公开的，可以被其他合约调用
    // msg.sender是合约调用者
    // internal比private多了继承访问权限
    function _createZombie(string _name, uint _dna) internal {
        uint id = zombies.push(Zombie(_name, _dna, 1, uint32(now + cooldownTime), 0, 0)) - 1;
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;
        NewZombie(id, _name, _dna);
    }

    // view访问修饰符表示该函数没有修改合约状态
    // pure访问修饰符表示该函数没有访问到函数外的变量
    // keccak256生成（256/4=64个字符随机16进制标记数） 
    function _generateRandomDna(string _str) private view returns (uint) {
        uint rand = uint(keccak256(_str));
        return rand % dnaModulus;
    }

    function createRandomZombie(string _name) public {
        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        randDna = randDna - randDna % 100;
        _createZombie(_name, randDna);
    }
}
