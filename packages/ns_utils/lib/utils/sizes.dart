import 'package:flutter/material.dart';

import '../src.dart';

const Size _defaultSize = Size(360, 690);

double defaultScreenWidth = _defaultSize.width;
double defaultScreenHeight = _defaultSize.width;
double screenWidth = _defaultSize.width;
double screenHeight = _defaultSize.height;

///Adapting screen and font size.
///Let your UI display a reasonable layout on different screen sizes!
///
class Sizes {
  Sizes._();

  static bool initialized = false;

  ///initialize sizes
  ///Should be called only once
  ///
  static void initScreenAwareSizes(
    BuildContext context, {
    Size designSize = _defaultSize,
  }) {
    if (initialized) {
      appLogsNS('Sizes already initialized');
      printScreenInformation();
      return;
    }
    initialized = true;

    screenWidth = context.sizeX.width;
    screenHeight = context.sizeX.height;

    if (screenWidth > 300 && screenWidth < 500) {
      defaultScreenWidth = 450;
      defaultScreenHeight = defaultScreenWidth * screenHeight / screenWidth;
    } else if (screenWidth > 500 && screenWidth < 600) {
      defaultScreenWidth = 500;
      defaultScreenHeight = defaultScreenWidth * screenHeight / screenWidth;
    } else if (screenWidth > 600 && screenWidth < 700) {
      defaultScreenWidth = 550;
      defaultScreenHeight = defaultScreenWidth * screenHeight / screenWidth;
    } else if (screenWidth > 700 && screenWidth < 1050) {
      defaultScreenWidth = 800;
      defaultScreenHeight = defaultScreenWidth * screenHeight / screenWidth;
    } else {
      defaultScreenWidth = screenWidth;
      defaultScreenHeight = screenHeight;
    }

    ScreenUtil.init(
      context,
      designSize: Size(defaultScreenWidth, defaultScreenHeight),
    );

    printScreenInformation();
  }

  static void printScreenInformation() {
    appLogsNS('''
    Device Screen Details
    screenWidth: $screenWidth
    screenHeight: $screenHeight
    ---------X--------X-----------
    defaultScreenWidth: $defaultScreenWidth
    defaultScreenHeight: $defaultScreenHeight
    
    Actual  : After(Width) 
    1      : ${1.w} 
    10     : ${10.w}
    15     : ${15.w}
    20     : ${20.w}
    100    : ${100.w}     
     
    Actual  : After(Height) 
    1      : ${1.h} 
    10     : ${10.h}
    15     : ${15.h}
    20     : ${20.h}
    100    : ${100.h}    
     
    Actual  : After(Radius) 
    10     : ${10.r}
    15     : ${15.r}
    20     : ${20.r}
     
    FontSize
    Actual : After
    15  :  ${15.sp} 
    20  :  ${20.sp}  
    
    ---------X--------X-----------
    Device width px: ${ScreenUtil().screenWidth}
    Device height px: ${ScreenUtil().screenHeight}
    Device pixel density: ${ScreenUtil().pixelRatio}
    Bottom safe zone distance dp: ${ScreenUtil().bottomBarHeight}
    Status bar height px: ${ScreenUtil().statusBarHeight}dp
    Ratio of actual width dp to design draft px: ${ScreenUtil().scaleWidth}
    Ratio of actual height dp to design draft px: ${ScreenUtil().scaleHeight}
    The ratio of font and width to the size of the design: ${ScreenUtil().scaleWidth}
    The ratio of  height width to the size of the design: ${ScreenUtil().scaleHeight}
    ''');
  }
}
