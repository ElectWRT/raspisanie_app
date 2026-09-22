/// С какого запуска впервые показывать благодарность. Не с первого:
/// сначала человек должен успеть приложением попользоваться.
const thanksFirstLaunch = 5;

/// Как часто повторять. Реже — забудется, чаще — начнёт раздражать.
const thanksInterval = Duration(days: 30);

/// Пора ли показать окно «спасибо, что пользуетесь».
///
/// [launchCount] — сколько раз приложение запускалось, включая текущий
/// запуск. [lastShown] — когда окно показывали в прошлый раз.
bool shouldShowThanks({
  required int launchCount,
  required DateTime? lastShown,
  required DateTime now,
}) {
  if (launchCount < thanksFirstLaunch) return false;
  if (lastShown == null) return true;
  return now.difference(lastShown) >= thanksInterval;
}
