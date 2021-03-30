#!/bin/sh

rm -f -r ./node_modules/react-native-zoom-bridge/ios/libs && \
mkdir -p ./node_modules/react-native-zoom-bridge/ios/libs && \
cd ./node_modules/react-native-zoom-bridge/ios/libs && \
curl -L https://github.com/zoom/zoom-sdk-ios/releases/download/v5.2.42037.1112/ios-mobilertc-all-5.2.42037.1112-clientlog.zip > file.zip && \
unzip file.zip && \
cd ios-mobilertc-all-5.2.42037.1112-clientlog/lib && \
mv * ../../ && \
cd ../../ && \
rm file.zip && \
rm -r ios-mobilertc-all-5.2.42037.1112-clientlog && \
rm -r __MACOSX
sed -i.bak 's/\#import <MobileRTC\//\#import </g' ./MobileRTC.framework/Headers/MobileRTC.h
sed -i.bak 's/\#import <MobileRTC\//\#import </g' ./MobileRTC.framework/Headers/MobileRTCMeetingService+AppShare.h
sed -i.bak 's/\#import <MobileRTC\//\#import </g' ./MobileRTC.framework/Headers/MobileRTCMeetingService+Audio.h
sed -i.bak 's/\#import <MobileRTC\//\#import </g' ./MobileRTC.framework/Headers/MobileRTCMeetingService+Chat.h
sed -i.bak 's/\#import <MobileRTC\//\#import </g' ./MobileRTC.framework/Headers/MobileRTCMeetingService+Customize.h
sed -i.bak 's/\#import <MobileRTC\//\#import </g' ./MobileRTC.framework/Headers/MobileRTCMeetingService+inMeeting.h
sed -i.bak 's/\#import <MobileRTC\//\#import </g' ./MobileRTC.framework/Headers/MobileRTCMeetingService+User.h
sed -i.bak 's/\#import <MobileRTC\//\#import </g' ./MobileRTC.framework/Headers/MobileRTCMeetingService+Video.h
sed -i.bak 's/\#import <MobileRTC\//\#import </g' ./MobileRTC.framework/Headers/MobileRTCMeetingService+VirtualBackground.h
sed -i.bak 's/\#import <MobileRTC\//\#import </g' ./MobileRTC.framework/Headers/MobileRTCMeetingService+Webinar.h
sed -i.bak 's/\#import <MobileRTC\//\#import </g' ./MobileRTC.framework/Headers/MobileRTCMeetingService+BO.h