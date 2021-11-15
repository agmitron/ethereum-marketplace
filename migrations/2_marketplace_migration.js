const CourseMarketplaceMigration = artifacts.require("CourseMarketplace");

module.exports = function (deployer) {
  deployer.deploy(CourseMarketplaceMigration);
};
