import 'package:event_bus/event_bus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 创建EventBus
EventBus eventBus = EventBus();

class Manager{
  Future writeShared(String key,String value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(key, value);
  }

  /*
   * 读取数据
   */
  Future<String> readShared(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.get(key);
  }

  /*
   * 删除数据
   */
  Future removeShared(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove(key);
  }

}