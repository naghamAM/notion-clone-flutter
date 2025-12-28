import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';


class SettingsScreen extends StatefulWidget {

  SettingsScreen();

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    ThemeProvider provider = context.watch();

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Appearance'),
            subtitle: Text('Customize how the app looks on your device.'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(title: Text('Appearance')),
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Choose Theme'),
                          Switch(
                            value:
                            Theme.of(context).brightness == Brightness.dark,
                            onChanged: (value) {
                              ThemeProvider provider = context.read();
                              provider.toggleTheme();
                              // widget.toggleTheme();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}