import 'package:flutter/material.dart';
import 'package:submission_story_app/utils/common.dart';
    
class SplashScreen extends StatelessWidget {

  const SplashScreen({ super.key });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.storyApp,
              style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 50),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}