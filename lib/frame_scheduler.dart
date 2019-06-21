import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// 向系統註冊監聽幀渲染的回調
/// 由於 [addPersistentFrameCallback] 註冊後無法解除
/// 因此只會執行一次
void registerFrameScheduler() {
  if (FrameScheduler.isRegistered) {
    print('FrameScheduler is registered.');
    return;
  }
  FrameScheduler.isRegistered = true;
  FrameScheduler.scheduler = SchedulerBinding.instance;
  FrameScheduler.scheduler.addPersistentFrameCallback(FrameScheduler.frameCallback);
  print('FrameScheduler is registered.');
}
/// 提供新增或解除監聽幀的類別
class FrameScheduler {
  /// 是否已向系統註冊全域的幀監聽回調
  static bool isRegistered = false;
  /// 系統的幀排程實體
  static SchedulerBinding scheduler;
  /// 自行定義的幀監聽器
  static Map<Key, FrameCallback> frameListeners = Map();
  /// 掛載到全域的幀監聽回調
  static FrameCallback frameCallback = (Duration timestamp) {
    if (FrameScheduler.frameListeners.length == 0) return;
    FrameScheduler.frameListeners.values.forEach((listener) { listener(timestamp); });
    // 請 UI 層繼續執行渲染
    FrameScheduler.scheduler.scheduleFrame();
  };
  /// 新增一筆幀監聽回調，回傳該回調的鍵值
  static Key addFrameListener(FrameCallback frameListener) {
    Key listenerKey = UniqueKey();
    FrameScheduler.frameListeners[listenerKey] = frameListener;
    return listenerKey;
  }
  /// 輸入回調的鍵值，移除該幀監聽回調
  static bool removeFrameListener(Key listenerKey) {
    bool isContainsKey = FrameScheduler.frameListeners.containsKey(listenerKey);
    if (isContainsKey) FrameScheduler.frameListeners.remove(listenerKey);
    return isContainsKey;
  }
  /// 移除所有的幀監聽回調
  static void removeAllFrameListeners() {
    FrameScheduler.frameListeners.clear();
  }
}