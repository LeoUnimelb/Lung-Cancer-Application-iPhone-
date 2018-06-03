# Lung-Cancer-Application
This is developed for COMP90055 Computing Project (25 Credit Points) by LE XI.

## Features
Help patients to:
* Track exercise
* Check progress
* Check doctors' advice
* Set/reset weekly exercise targets

Help doctors to:
* Better monitor and manage patients' conditions
* Guide patients to set their weekly exercise targets
* Remind patients if there are any changes in current weekly exercise targets

Auxiliary Functionalities:
* Authentication
* Weather Condition Alert
* Local Data Backup
* Charts and Animated Progress Bars

## Requirements
* iOS 10.0+ 
* Xcode 9.0+

## Set Up
You can use CocoaPods to install needed libraries. Add following lines to your Podfile and then  install:
```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target 'lung_v1' do
    pod 'Alamofire', '~> 4.7'
    pod 'LTMorphingLabel'
    pod 'Firebase/Core'
    pod 'Firebase/Database'
    pod 'SwiftCharts', '~> 0.6.1'
    pod 'OHMySQL'
end
```
## To Run this Project:
1. Open lung_v1.xcworkspace instead of lung_v1.xcodeproj in the project folder.<br>
2. Set an Apple team account in the general signing settings.<br>
3. Connect an iPhone to Xcode, build and run this project. An iphone is required to use all features since Pedometer is not supported on iOS simulators.<br>
4. Login using one of the following tokens and then start to use:
* Alana:AF929CB2-7EB5-4568-AA60-4FAB03A1DF8D
* Baker:AAC46A62-A21C-4037-8730-0C51006D416F
* Clay:3262141D-6E02-4D36-A903-754FC4B96B1C
* Diana:E38B454A-0632-46B5-8328-F5A2DC428E68
* Emma:C37F3FD9-9F47-4E14-9FB9-233AE7252E47

## Communication
If you have questions, please contact me lxi@student.unimelb.edu.au

## Video of the application
https://youtu.be/ydiJGahNLDs
