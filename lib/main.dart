import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io';

void main() {
  runApp(const App());
}

class Tag {
  final int id;
  final String code;

  Tag(this.id, this.code);
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter QR Code',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const HomePage(title: 'Melhor Ponto'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey key = GlobalKey(debugLabel: 'QR');
  final List tags = [];
  QRViewController? controller;
  bool camera = false;

  @override
  void reassemble() {
    super.reassemble();

    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  void created(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) {
      if (scanData.code!.isNotEmpty) add(Tag(1, scanData.code as String));
    });
  }

  void toggle() async {
    bool value = !camera;

    if (!value) {
      await controller!.pauseCamera();
    }

    setState(() {
      camera = value;
    });
  }

  void add(Tag tag) async {
    await controller!.pauseCamera();

    setState(() {
      camera = false;
      tags.add(tag);
    });
  }

  void remove(int index) {
    setState(() {
      tags.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (tags.isEmpty)
                  const Text(
                    'No tags found...',
                  ),
                if (tags.isNotEmpty)
                  Expanded(
                    child: SizedBox(
                      height: 200.0,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: tags.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 8.0, left: 16.0, bottom: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                      child: Container(
                                    padding:
                                        const EdgeInsets.only(right: 8.0),
                                    child: Text('${tags[index].code}',
                                        overflow: TextOverflow.ellipsis),
                                  )),
                                  MaterialButton(
                                    minWidth: 0,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    color: Colors.purple,
                                    textColor: Colors.white,
                                    shape: const CircleBorder(),
                                    onPressed: () => remove(index),
                                    child: const Icon(Icons.remove),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (camera)
            SizedBox.expand(
              child: QRView(
                key: key,
                onQRViewCreated: created,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.purple,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: 250,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: camera ? 'Cancel' : 'Add',
        backgroundColor: Colors.purple,
        onPressed: toggle,
        child: camera ? const Icon(Icons.close) : const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
