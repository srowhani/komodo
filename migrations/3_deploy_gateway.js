const KomodoGateway = artifacts.require("./KomodoGateway.sol");

module.exports = function(deployer) {
  deployer.deploy(KomodoGateway, []);
};
