const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("Sp33dFunModule", (m) => {
  
  const sp33dFun = m.contract("Sp33dFun");

  return { sp33dFun };
});
