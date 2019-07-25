/// 難度的型別宣告
enum Level {
  easy,
  medium,
  difficult
}
/// 對應難度的顯示文字
const LevelText = {
  Level.easy: '簡單',
  Level.medium: '中等',
  Level.difficult: '困難',
};
/// 遊戲設定
class GameConfigs {
  Level mineweeperLevel;
  GameConfigs({
    this.mineweeperLevel,
  });
}