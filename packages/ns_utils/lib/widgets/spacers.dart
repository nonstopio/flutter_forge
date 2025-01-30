import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class P1 extends StatelessWidget {
  const P1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(1.w));
  }
}

class P2 extends StatelessWidget {
  const P2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(2.w));
  }
}

class P5 extends StatelessWidget {
  const P5({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(5.w));
  }
}

class P8 extends StatelessWidget {
  const P8({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(8.w));
  }
}

class P10 extends StatelessWidget {
  const P10({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(10.w));
  }
}

class PH10 extends StatelessWidget {
  const PH10({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.symmetric(horizontal: 10.w));
  }
}

class P20 extends StatelessWidget {
  const P20({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(20.w));
  }
}

class P30 extends StatelessWidget {
  const P30({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(30.w));
  }
}

class P40 extends StatelessWidget {
  const P40({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(40.w));
  }
}

class C0 extends StatelessWidget {
  const C0({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink(key: key);
  }
}

class C1 extends StatelessWidget {
  final Color? color;

  const C1({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Colors.transparent,
      height: 1.w,
      width: 1.w,
    );
  }
}

class C2 extends StatelessWidget {
  final Color? color;

  const C2({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Colors.transparent,
      height: 2.w,
      width: 2.w,
    );
  }
}

class C3 extends StatelessWidget {
  final Color? color;

  const C3({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Colors.transparent,
      height: 3.w,
      width: 3.w,
    );
  }
}

class C4 extends StatelessWidget {
  final Color? color;

  const C4({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Colors.transparent,
      height: 4.w,
      width: 4.w,
    );
  }
}

class C5 extends StatelessWidget {
  final Color? color;

  const C5({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Colors.transparent,
      height: 5.w,
      width: 5.w,
    );
  }
}

class C6 extends StatelessWidget {
  final Color? color;

  const C6({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Colors.transparent,
      height: 6.w,
      width: 6.w,
    );
  }
}

class C8 extends StatelessWidget {
  final Color? color;

  const C8({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Colors.transparent,
      height: 8.w,
      width: 8.w,
    );
  }
}

class C10 extends StatelessWidget {
  final Color? color;

  const C10({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Colors.transparent,
      height: 10.w,
      width: 10.w,
    );
  }
}

class C15 extends StatelessWidget {
  final Color? color;

  const C15({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Colors.transparent,
      height: 15.w,
      width: 15.w,
    );
  }
}

class C20 extends StatelessWidget {
  final Color? color;

  const C20({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Colors.transparent,
      height: 20.w,
      width: 20.w,
    );
  }
}

class C40 extends StatelessWidget {
  final Color? color;

  const C40({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Colors.transparent,
      height: 40.w,
      width: 40.w,
    );
  }
}

class C30 extends StatelessWidget {
  final Color? color;

  const C30({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Colors.transparent,
      height: 30.w,
      width: 30.w,
    );
  }
}

class C50 extends StatelessWidget {
  final Color? color;

  const C50({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Colors.transparent,
      height: 50.w,
      width: 50.w,
    );
  }
}

class C100 extends StatelessWidget {
  final Color? color;

  const C100({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Colors.transparent,
      height: 100.w,
      width: 100.w,
    );
  }
}

class C150 extends StatelessWidget {
  final Color? color;

  const C150({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Colors.transparent,
      height: 150.w,
      width: 150.w,
    );
  }
}
