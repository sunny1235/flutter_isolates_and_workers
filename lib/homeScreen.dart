import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isolated_worker/isolated_worker.dart';
import 'package:isolated_worker/js_isolated_worker.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});


  Future<void> workerForWeb() async {
    
    final bool loaded = await JsIsolatedWorker().importScripts(['js/addition.js']);
    if (loaded) {
      try {
        final a = await JsIsolatedWorker()
            .run(
              functionName: 'addTen',
              arguments: 45,
              fallback: () {
                return Future.value("okay nothing returned");
              },
            );
          print("DATA :: $a");
      } catch (e) {
        print("ERROR:: $e");
      }
    } else {
      print('Web worker is not available :(');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HOme sCreen"),
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () async {
              if (kIsWeb) {
                workerForWeb();
              } else {
                // implement isolates
                // print("clicked  one");
                // final receivePort = ReceivePort();
                // await Isolate.spawn(appIsolation, receivePort.sendPort);
              }
            },
            child: !kIsWeb
                ? const Text("Compute other platform isoalted taskss")
                : const Text("Compute web's isoalted task"),
          ),
          TextButton(
            onPressed: () async {
              final p = ReceivePort();

              final data = {'port': p.sendPort, 'data': 'here is some data.'};

              final isolate = await Isolate.spawn(heavyFunction, data);

              // you can get only the first element like this
              // final computedData = await p.first;
              // print("first Data :: $computedData");

              // But if you want to get more data you can use listen method
              // p.listen((message) {
              //   print("message :: $message");
              // });
              // or for loop

              await for (var item in p) {
                print("alternative msg item :: $item");
              }
            },
            child: const Text("mock click"),
          )
        ],
      ),
    );
  }
}

// Top Level Function
void heavyFunction(Map<String, dynamic> map) {
  final SendPort port = map['port'];
  final String data = map['data'];

  // Heavy computing process
  final computedData = "someOne is working, $data";
  // int sum = 0;
  // for (var i = 0; i < 100000000; i++) {
  //   sum += i;
  // }
  //  you can send data using stream of port without killing the isolate
  port.send('data1');
  port.send('data2');
  port.send('data3');

  

  // Send back the computedData and kill the isolate
  Isolate.exit(port, computedData);
}
