# Changelog

All notable changes to this project will be documented in this file.

## 0.0.12, 0.0.14, 0.0.15
- Standardized documentation to match API implementation
- Fixed inconsistencies in parameter naming (task_id vs taskId)
- Clarified file upload status codes (2=in progress, 3=completed, 4=error)
- Updated examples in README to accurately reflect API response format
- Improved file upload documentation with clearer examples

## 0.0.11
- Update SDK environment from '>=2.14.0 <3.0.0' to '>=2.14.0 <4.0.0' for Dart 3 compatibility
- Replace flutter_uploader with Dio for file uploads, removing external dependency
- Improve file upload handling and progress monitoring
- Remove unnecessary print statements to improve performance
- Improve socket connection handling and stability
- Enhance error handling in API requests
- Standardize socket event naming
- Fix socket initialization with proper disposal of previous connections
- Optimize code for better SDK integration
- Fix potential memory leaks in socket connections

## 0.0.10
- Update params create room
- Add show notification at example 

## 0.0.9
- Upgrade version socket.io to V2 

## 0.0.8
- Remove firebase_message

## 0.0.7
- Support message notification
- Update document and sample

## 0.0.6
- Support to upload files on background
- Return message 
- Update document and sample

## 0.0.5
- We limit timer for message sending
- Change content-type image
- Refresh config information

## 0.0.4
- Allow to send sticker

## 0.0.3
- Fix cast error on 3.3.10

## 0.0.2
- Update sending and receive model

## 0.0.1
* Release basic version. 