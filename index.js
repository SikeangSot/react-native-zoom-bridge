import { NativeModules } from "react-native";

const {
  RNZoomBridge,
  RNZoomUsBridgeEventEmitter: _RNZoomUsBridgeEventEmitter,
} = NativeModules;

export default RNZoomBridge;
export const RNZoomUsBridgeEventEmitter = _RNZoomUsBridgeEventEmitter;
