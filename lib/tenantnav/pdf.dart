import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class pdf extends StatefulWidget {
  final String pdfUrl;

  const pdf({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  _pdfState createState() => _pdfState();
}

class _pdfState extends State<pdf> {
  Future<void> _openPdfUrl() async {
    if (await canLaunch(widget.pdfUrl)) {
      await launch(widget.pdfUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('There is no PDF present for rules and regulations.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _openPdfUrl,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.black,
          ),
          child: Text('Open PDF'),
        ),
      ),
    );
  }
}
