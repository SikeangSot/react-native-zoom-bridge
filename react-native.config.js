const path = require('path');
​
module.exports = {
	dependency: {
		platforms: {
			android: {
				packageImportPath: "import com.appgoalz.reactnative.RNZoomBridgePackage;",
				packageInstance: "new RNZoomBridgePackage()"
			}
		}
  }
};
