const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("Sp33dFunTokenModule", (m) => {
  const sp33dFunToken = m.contract("Sp33dFunToken");

  return { sp33dFunToken };
});
