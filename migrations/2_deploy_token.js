const KomodoToken = artifacts.require("./KomodoToken.sol");

module.exports = function(deployer) {
  deployer.deploy(KomodoToken, []);
};
