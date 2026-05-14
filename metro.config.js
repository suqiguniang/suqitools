const {getDefaultConfig, mergeConfig} = require('@react-native/metro-config');

/**
 * Metro configuration
 * <url id="" type="url" status="" title="" wc="">https://reactnative.dev/docs/metro</url>
 *
 * @type {import('metro-config').MetroConfig}
 */
const config = {
  resolver: {
    assetExts: ['png', 'jpg', 'jpeg', 'gif', 'webp', 'svg'],
  },
};

module.exports = mergeConfig(getDefaultConfig(__dirname), config);