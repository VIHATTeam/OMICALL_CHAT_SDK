import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:livetalk_sdk/entity/entity.dart';
import 'package:livetalk_sdk/livetalk_sdk.dart';

class SocketTestScreen extends StatefulWidget {
  final String roomId;
  final String uuid;

  const SocketTestScreen({
    Key? key,
    required this.roomId,
    required this.uuid,
  }) : super(key: key);

  @override
  _SocketTestScreenState createState() => _SocketTestScreenState();
}

class _SocketTestScreenState extends State<SocketTestScreen> {
  List<String> logs = [];
  late StreamSubscription<LiveTalkEventEntity> _eventSubscription;
  bool isConnected = false;
  String? lastEvent;
  
  // Danh sách các endpoint có thể sử dụng
  final List<String> endpoints = [
    'https://socket-event-v1-stg.omicrm.com',
    'https://socket-event-v1.omicrm.com',
    'https://socket-event.omicrm.com',
  ];
  
  // Index endpoint hiện tại
  int currentEndpointIndex = 0;
  final TextEditingController _customEndpointController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _listenForSocketEvents();
    _addLog("Khởi tạo màn hình kiểm tra socket...");
    _checkNetworkStatus();
  }

  void _listenForSocketEvents() {
    _eventSubscription = LiveTalkSdk.shareInstance.eventStream.listen((event) {
      _addLog("Sự kiện nhận được: ${event.eventName}");
      setState(() {
        lastEvent = event.eventName;
        
        if (event.eventName == "connected") {
          isConnected = true;
        } else if (event.eventName == "disconnect") {
          isConnected = false;
        }
      });
    });
  }

  void _addLog(String message) {
    setState(() {
      logs.add("${DateTime.now().toString().split('.').first}: $message");
      if (logs.length > 100) {
        logs.removeAt(0);
      }
    });
  }
  
  Future<void> _checkNetworkStatus() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _addLog("Kết nối mạng: Đã kết nối");
      }
    } on SocketException catch (_) {
      _addLog("Kết nối mạng: Không có kết nối");
    }
  }

  @override
  void dispose() {
    _eventSubscription.cancel();
    _customEndpointController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kiểm tra Socket"),
        actions: [
          Container(
            margin: EdgeInsets.all(8),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected ? Colors.green : Colors.red,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: logs.length,
              reverse: true,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(logs[logs.length - 1 - index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Room ID: ${widget.roomId}", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("UUID: ${widget.uuid}", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Trạng thái kết nối: ${isConnected ? 'Đã kết nối' : 'Ngắt kết nối'}", 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isConnected ? Colors.green : Colors.red,
                      )
                    ),
                    if (lastEvent != null)
                      Text("Sự kiện cuối: $lastEvent", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Chọn Endpoint:", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    ...List.generate(endpoints.length, (index) {
                      return RadioListTile<int>(
                        title: Text(endpoints[index], style: TextStyle(fontSize: 12)),
                        value: index,
                        groupValue: currentEndpointIndex,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              currentEndpointIndex = value;
                            });
                          }
                        },
                        dense: true,
                      );
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _customEndpointController,
                        decoration: InputDecoration(
                          labelText: "Endpoint tùy chỉnh",
                          hintText: "https://your-socket-endpoint.com",
                          isDense: true,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _addLog("Đang thử kết nối lại...");
                    _reconnectWithSelectedEndpoint();
                  },
                  child: Text("Kết nối lại"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _addLog("Đang ngắt kết nối...");
                    LiveTalkSdk.shareInstance.disconnect();
                  },
                  child: Text("Ngắt kết nối"),
                ),
                ElevatedButton(
                  onPressed: _checkNetworkStatus,
                  child: Text("Kiểm tra mạng"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _reconnectWithSelectedEndpoint() async {
    try {
      _addLog("Thử kết nối lại với socket...");
      
      // Buộc kết nối lại socket
      await LiveTalkSdk.shareInstance.forceReconnectSocket();
      
      _addLog("Yêu cầu kết nối lại thành công");
    } catch (e) {
      _addLog("Lỗi khi kết nối lại: $e");
    }
  }
} 