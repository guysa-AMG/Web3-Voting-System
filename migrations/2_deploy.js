

const VoteICC = artifacts.require("VoteICC")


module.exports = function (deployer){
    deployer.deploy(VoteICC,[17,34,47,53],3600)
}