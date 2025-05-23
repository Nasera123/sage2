import 'package:get/get.dart';

class NavigationController extends GetxController {
  final _currentIndex = 0.obs;
  
  int get currentIndex => _currentIndex.value;
  
  void setCurrentIndex(int index) {
    _currentIndex.value = index;
  }
} 