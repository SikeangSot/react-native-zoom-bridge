
#import "RNZoomBridge.h"
#import "RNZoomUsBridgeEventEmitter.h"

@implementation RNZoomBridge
{
  BOOL isInitialized;
  RCTPromiseResolveBlock initializePromiseResolve;
  RCTPromiseRejectBlock initializePromiseReject;
  RCTPromiseResolveBlock meetingPromiseResolve;
  RCTPromiseRejectBlock meetingPromiseReject;
}

static RNZoomUsBridgeEventEmitter *internalEmitter = nil;

- (instancetype)init {
  if (self = [super init]) {
    isInitialized = NO;
    initializePromiseResolve = nil;
    initializePromiseReject = nil;
    meetingPromiseResolve = nil;
    meetingPromiseReject = nil;
  }
  return self;
}

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(
  initialize: (NSString *)appKey
  withAppSecret: (NSString *)appSecret
  withWebDomain: (NSString *)webDomain
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  if (isInitialized) {
    resolve(@"Already initialize Zoom SDK successfully.");
    return;
  }

  isInitialized = true;

  @try {
    initializePromiseResolve = resolve;
    initializePromiseReject = reject;

    [[MobileRTC sharedRTC] setMobileRTCDomain:webDomain];

    MobileRTCAuthService *authService = [[MobileRTC sharedRTC] getAuthService];
    if (authService)
    {
      authService.delegate = self;

      authService.clientKey = appKey;
      authService.clientSecret = appSecret;

      [authService sdkAuth];
    } else {
      NSLog(@"onZoomSDKInitializeResult, no authService");
    }
  } @catch (NSError *ex) {
      reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing initialize", ex);
  }
}

RCT_EXPORT_METHOD(
  startMeeting: (NSString *)displayName
  withMeetingNo: (NSString *)meetingNo
  withUserId: (NSString *)userId
  withUserType: (NSInteger)userType
  withZoomAccessToken: (NSString *)zoomAccessToken
  withZoomToken: (NSString *)zoomToken
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  @try {
    meetingPromiseResolve = resolve;
    meetingPromiseReject = reject;

    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (ms) {
      ms.delegate = self;

      MobileRTCMeetingStartParam4WithoutLoginUser * params = [[MobileRTCMeetingStartParam4WithoutLoginUser alloc]init];
      params.userName = displayName;
      params.meetingNumber = meetingNo;
      params.userID = userId;
      params.userType = (MobileRTCUserType)userType;
      params.zak = zoomAccessToken;
      params.userToken = zoomToken;

      MobileRTCMeetError startMeetingResult = [ms startMeetingWithStartParam:params];
      NSLog(@"startMeeting, startMeetingResult=%d", startMeetingResult);
    }
  } @catch (NSError *ex) {
      reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing startMeeting", ex);
  }
}

RCT_EXPORT_METHOD(
  joinMeeting: (NSString *)displayName
  withMeetingNo: (NSString *)meetingNo
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  @try {
    meetingPromiseResolve = resolve;
    meetingPromiseReject = reject;

    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (ms) {
      ms.delegate = self;

      NSDictionary *paramDict = @{
        kMeetingParam_Username: displayName,
        kMeetingParam_MeetingNumber: meetingNo
      };

      MobileRTCMeetError joinMeetingResult = [ms joinMeetingWithDictionary:paramDict];
      NSLog(@"joinMeeting, joinMeetingResult=%d", joinMeetingResult);
    }
  } @catch (NSError *ex) {
      reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing joinMeeting", ex);
  }
}

RCT_EXPORT_METHOD(
    joinMeetingWithPassword: (NSString *)displayName
    withMeetingNo: (NSString *)meetingNo
    withPassword: (NSString *)password
    withResolve: (RCTPromiseResolveBlock)resolve
    withReject: (RCTPromiseRejectBlock)reject
)
{
    @try {
      meetingPromiseResolve = resolve;
      meetingPromiseReject = reject;
    
      MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
      if (ms) {
        ms.delegate = self;
    
        NSDictionary *paramDict = @{
          kMeetingParam_Username: displayName,
          kMeetingParam_MeetingNumber: meetingNo,
          kMeetingParam_MeetingPassword: password
        };
        
        MobileRTCMeetError joinMeetingResult = [ms joinMeetingWithDictionary:paramDict];
        NSLog(@"joinMeeting, joinMeetingResult=%d", joinMeetingResult);
      }
    } @catch (NSError *ex) {
        reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing joinMeeting", ex);
    }
}

- (void)onMobileRTCAuthReturn:(MobileRTCAuthError)returnValue {
  NSLog(@"nZoomSDKInitializeResult, errorCode=%d", returnValue);
    RNZoomUsBridgeEventEmitter *emitter = [RNZoomUsBridgeEventEmitter allocWithZone: nil];
  if(returnValue != MobileRTCAuthError_Success) {
      [emitter userSDKInitilized:@{@"error": @"Error on initialize", }];
    initializePromiseReject(
      @"ERR_ZOOM_INITIALIZATION",
      [NSString stringWithFormat:@"Error: %d", returnValue],
      [NSError errorWithDomain:@"us.zoom.sdk" code:returnValue userInfo:nil]
    );
  } else {
    [emitter userSDKInitilized:@{}];
    initializePromiseResolve(@"Initialize Zoom SDK successfully.");
  }
}

- (void)onMeetingReturn:(MobileRTCMeetError)errorCode internalError:(NSInteger)internalErrorCode {
  NSLog(@"onMeetingReturn, error=%d, internalErrorCode=%zd", errorCode, internalErrorCode);

  if (!meetingPromiseResolve) {
    return;
  }

  if (errorCode != MobileRTCMeetError_Success) {
    meetingPromiseReject(
      @"ERR_ZOOM_MEETING",
      [NSString stringWithFormat:@"Error: %d, internalErrorCode=%zd", errorCode, internalErrorCode],
      [NSError errorWithDomain:@"us.zoom.sdk" code:errorCode userInfo:nil]
    );
  } else {
    meetingPromiseResolve(@"Connected to zoom meeting");
  }

  meetingPromiseResolve = nil;
  meetingPromiseReject = nil;
}

- (void)onMeetingStateChange:(MobileRTCMeetingState)state {
  NSLog(@"onMeetingStatusChanged, meetingState=%d", state);

   RNZoomUsBridgeEventEmitter *emitter = [RNZoomUsBridgeEventEmitter allocWithZone: nil];
   
    if(state == MobileRTCMeetingState_Idle) {
         [emitter userStateChange:@{@"state": @"idle" }];
        [self leaveMeeting];
    }
    
    if(state == MobileRTCMeetingState_InMeeting) {
        [emitter userStateChange:@{@"state": @"inMeeting" }];
        [emitter userStartedAMeeting:@{@"state": @"startMeeting"}];
    }
    
  if (state == MobileRTCMeetingState_InMeeting || state == MobileRTCMeetingState_Idle) {
    if (!meetingPromiseResolve) {
      return;
    }

    meetingPromiseResolve(@"Connected to zoom meeting");

    meetingPromiseResolve = nil;
    meetingPromiseReject = nil;
  }
}

- (void)onMeetingError:(MobileRTCMeetError)errorCode message:(NSString *)message {
  NSLog(@"onMeetingError, errorCode=%d, message=%@", errorCode, message);
    RNZoomUsBridgeEventEmitter *emitter = [RNZoomUsBridgeEventEmitter allocWithZone: nil];
  if (!meetingPromiseResolve) {
    return;
  }else {
      [emitter meetingErrored:@{@"error": [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", errorCode, message]}];
  }
  
  meetingPromiseReject(
    @"ERR_ZOOM_MEETING",
    [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", errorCode, message],
    [NSError errorWithDomain:@"us.zoom.sdk" code:errorCode userInfo:nil]
  );

  meetingPromiseResolve = nil;
  meetingPromiseReject = nil;
}

- (void)onWaitingRoomStatusChange:(BOOL)needWaiting
{
   NSLog(@"onWaitingRoomStatusChange, needWaiting=%d", needWaiting);
    if (needWaiting) {
        // waiting room not supported lets leave meeting
        RNZoomUsBridgeEventEmitter *emitter = [RNZoomUsBridgeEventEmitter allocWithZone: nil];
        [emitter meetingWaitingRoomIsActive:@{}];
        [self leaveMeeting];
    }
}

- (void) onSinkMeetingUserLeft:(NSUInteger)userID {
    RNZoomUsBridgeEventEmitter *emitter = [RNZoomUsBridgeEventEmitter allocWithZone: nil];
    [emitter userEndedTheMeeting:@{@"userId": [NSString stringWithFormat:@"%d", userID]}];
}

- (void)leaveMeeting {
  MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
  if (!ms) return;
  [ms leaveMeetingWithCmd:LeaveMeetingCmd_Leave];
  RNZoomUsBridgeEventEmitter *emitter = [RNZoomUsBridgeEventEmitter allocWithZone: nil];
  [emitter userEndedTheMeeting:@{}];
}


@end
