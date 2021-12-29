# trap_daemon
## Trap daemon for Dune mediaplayers

  Используйте на свой страх и риск. 
  Не используйте, если на вашем медааплеере запущен сервер типа transmission 
  или еще какой-либо софт, постоянно качающий данные.
  
  Данный скрипт ищет на медаплеере зависшие коннекции медиапотоков, 
  образующиеся при обрыве внешнего соединения с интернет более чем на 90 секунд.
  
  В этом случае оболочка плеера может подвиснуть и отображать лишь элементы 
  управления потоком. Выход в главное меню или в меню плагина окажется недоступным,
  даже если соединение с интеренет будет восстановлено.
  Единственный выход - аппаратная перезагрузка медиаплеера кнопкой питания.
  
  Для исправления этой ошибки и предназначен данный скрипт. Скрипт отыскивает 
  действительно подвисшее соединенее источником медтиаконтента вне вашей сети 
  класса "C" (т.е. наружу). Если ситуация неисправима, скрипт через 90 секунд 
  после обрыва связи и непоявления внешней сети срубает оболочку медиаплеера, 
  запуская  её заново. Текущая позиция воспроизведения не сохраняется. 
  Но по крайней мере вы можете перезапустить свой плагин не вставая с дивана.
  
  В некоторых случаях, вы не сможете запустить проигрывание файла. Плеер будет 
  рапортовать: "Воспроизведение файла невозможно". Это значить, что вам все-таки 
  нужна перезагрузка плеера при помощи запуска специального плагина, пункта меню
  в настройках или кнопки питания плеера.
  
## Что нужно для использования этого демона.
  1. Наличие системного накопителя
  2. Установленный комплект LTU https://forum.hdtv.ru/index.php?showtopic=9727
  3. Минимальное умение работать с командной строкой

## Тестовый запуск
  - Скопируйте trap_daemon.sh на ваш медиаплеер
  - Подключитесь к консоли и перейдите в тот каталог, куда вы скопировали скрипт
  - Установите права на выполнение


    chmod 755 trap_daemon.sh

  - Запустите скрипт в тестовом режиме. Убедитесь, что единичка присутствует как аргумент


    ./trap_daemon.sh 1
  
  Можете экспериментировать с внешним кабелем соединяющим роутер с интернет и 
  реакцией экранного лога на обнаружение внешнего соединения и отработку его зависания.
  Если плеер не стоял на паузе, а именно играл внешний файл, то при пропадании связи 
  более чем на 90 секунд будет послан сигнал на рестарт оболочки. 
  Сам скрипт при этом продолжит работу. Остановить работу скрипта можно нажатием CTRL+C
  
  Если вас всё устраивает, то вы можете переместить скрипт в каталог /config/boot/

    mv trap_daemon.sh /config/boot/

  В этом случает демон будет запускаться автоматически при старте медиаплеера

## Решение проблем

  Если после тестового использования проблем не было, то и далее возникнуть их не должно.
  Однако на всякий случай предусмотрен механизм блокировки старта демона при загрузке.
  Просто сотрите файл скрипта из каталога /config/boot/

    rm -f /config/boot/trap_daemon.sh
    
  Если вы сами что-то координально меняли в скрипте и ваш медиаплеер перестал загружаться,
  можно предовратить загрузку демона при старте системы. Сделать это можно путем размещения 
  файла no_trap.txt (пустого или с любым содержанием) в корне системного накопителя.
  
  Выключите питание. Подсоедините системный накопитель к устройству позволяющему работать
  с его файловой системой (например Linux как флэшка https://www.slax.org/ ) и поместите файл
  no_trap.txt в корень вашего системного накопителя. Отмонтируйте накопитель (или выключите Linux).
  Вставляйте ваш накопитель в медиаплеер и загружайтесь.
  
  Если загрузиться всё-равно не удается, значит дело возможно и не в скрипте и вероятно вам 
  нужна флэшка с файлом dune_boot_reset_settings.flag в корне файловой системы, 
  воткнутая в USB разъем плеера. Это штатный способ сбросить все настройки окирпиченного плеера.
  
 
