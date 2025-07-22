
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';  

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Onboarding"),),
        body:Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Onboarding"),
              SvgPicture.asset("assets/images/frame1.svg"),

              ElevatedButton(onPressed: (){}, child: const Text("Next"))
            ],
          ),
        )
        


    );
  }
}