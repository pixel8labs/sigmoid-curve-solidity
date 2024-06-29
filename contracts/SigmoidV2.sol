// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BytesLib.sol";

library SigmoidV2 {
    bytes constant sigmoidValues = hex"000fe0d200115f030013047b0014d5260016d551001909b0001b7764001e2405002115aa002452f20027e30d002bcdc000301b740034d535003a04c0003fb4800045ef98004cc1dc005437d3005c5eaf00654441006ef6e9007985800084ff3800917378009ef1ab00ad890900bd485400ce3d8c00e0759500f3fbdb0108d9e9011f16f70136b780014fbcca016a24830185e85501a2fd9c01c1552601e0db0e020176bc02230b020245766402689381028c39a502b03d7b02d471d802f8a899031cb39203406573036392ab0386123903a7be5d03c8752d03e81907040690d50423c838043faf80045a3b95047365b2048b2b1e04a18cc704b68ed504ca383f04dc925804eda85e04fd8713050c3c5e0519d6f1052665fa0531f8e3053c9f14054667c8054f61e205579bd0055f23730566060c056c503605720dd805774a26057c0f9f0580681005845c9a0587f5b3058b3b35058e345b0590e7d505935bc6059595d305979b2b0599708a059b1a49059c9c5f059dfa6a059f37b905a0574e05a15be905a2480805a31df205a3dfb805a48f3905a52e2c05a5be1d05a6407405a6b67805a7215205a7820e05a7d9a005a828e705a870a905a8b19e05a8ec6905a921a005a951ca05a97d6105a9a4d505a9c88905a9e8da05aa061805aa208e05aa388105aa4e2d05aa61ca05aa738a05aa839905aa922105aa9f4805aaab2f05aab5f305aabfb205aac88305aad07e05aad7b605aade3e05aae42805aae98105aaee5805aaf2b905aaf6b005aafa4605aafd8505ab007405ab031c05ab058405ab07b105ab09a805ab0b7005ab0d0d05ab0e8205ab0fd405ab110605ab121a05ab131405ab13f705ab14c405ab157d05ab162505ab16bc05ab174605ab17c205ab183205ab189805ab18f405ab194805ab199305ab19d705ab1a1505ab1a4d";

    function getSigmoidValue(uint index) public pure returns (uint32) {
        require(index < 168, "Index out of bounds");
        return BytesLib.toUint32(sigmoidValues, index* 4);
    }
}
