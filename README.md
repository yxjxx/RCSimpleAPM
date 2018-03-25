# RCSimpleAPM

[![CI Status](http://img.shields.io/travis/yxjxx/RCSimpleAPM.svg?style=flat)](https://travis-ci.org/yxjxx/RCSimpleAPM)
[![Version](https://img.shields.io/cocoapods/v/RCSimpleAPM.svg?style=flat)](http://cocoapods.org/pods/RCSimpleAPM)
[![License](https://img.shields.io/cocoapods/l/RCSimpleAPM.svg?style=flat)](http://cocoapods.org/pods/RCSimpleAPM)
[![Platform](https://img.shields.io/cocoapods/p/RCSimpleAPM.svg?style=flat)](http://cocoapods.org/pods/RCSimpleAPM)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

RCSimpleAPM is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RCSimpleAPM'
```

## Usage

```objc
[[RCPerformanceRecorder sharedRecorder] monitorImageLibPerformanceWithEngineName:@"BDWebImage" andDuration:20 callback:^(UIViewController *resultVC) {
    [navigationController pushViewController:resultVC animated:YES];
}];
```

## Author

yxjxx, yangjing.rico@bytedance.com

## License

RCSimpleAPM is available under the MIT license. See the LICENSE file for more info.
