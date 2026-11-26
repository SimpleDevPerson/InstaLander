// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get timelineHelpTitle => 'Cómo leer la Timeline';

  @override
  String timelineNewFollowers(int count) {
    return '$count nuevos';
  }

  @override
  String timelineLostFollowers(int count) {
    return '$count perdidos';
  }

  @override
  String get archiveImportTitle => '¿Cómo quieres importar el ZIP?';

  @override
  String get archiveFollowersOnly => 'Solo seguidores';

  @override
  String get archiveFollowersOnlyDescription =>
      'Actualiza los seguidores y conserva los seguidos, el historial y la lista blanca.';

  @override
  String get archiveRestart => 'Empezar de cero';

  @override
  String get archiveRestartDescription =>
      'Importa seguidores y seguidos, eliminando el historial y la lista blanca anteriores.';

  @override
  String get archiveRestartRequiresBoth =>
      'Para empezar de cero, el ZIP debe contener tanto seguidores como seguidos.';

  @override
  String timelineFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos importados',
      one: '1 archivo importado',
    );
    return '$_temp0';
  }

  @override
  String get duplicateFollowerTitle => 'Archivo de seguidores ya importado';

  @override
  String duplicateFollowerDescription(String arg0) {
    return 'Ya has importado «$arg0». Se ha bloqueado la importación. Selecciona archivos de una nueva exportación.';
  }

  @override
  String get timelineProfilesView => 'Perfiles';

  @override
  String get timelineFilesView => 'Archivos importados';

  @override
  String get timelineFilesEmpty => 'Todavía no has importado archivos.';

  @override
  String get timelineLegacyImport => 'Importación anterior';

  @override
  String get timelineRemoveFile => 'Eliminar importación';

  @override
  String timelineRemoveFileDescription(String arg0) {
    return '¿Quieres quitar «$arg0» del historial? El Informe y la Cronología se volverán a calcular con los archivos restantes.';
  }

  @override
  String get timelineRemoveFileError => 'No se pudo eliminar la importación.';

  @override
  String get exportArtifacts => 'Artefactos de la exportación de Instagram';

  @override
  String get addToWhitelist => 'Añadir a la lista blanca';

  @override
  String get pickInstagramFilesTitle =>
      'Selecciona archivos JSON o un ZIP de Instagram';

  @override
  String get pickOneArchiveOrJson =>
      'Selecciona un archivo ZIP o uno o varios archivos JSON.';

  @override
  String get followerWhitelistTitle => 'Filtro por número de seguidores';

  @override
  String get followerWhitelistDescription =>
      'Añade automáticamente a la lista blanca todos los perfiles con más seguidores que el umbral establecido. Puede tardar unos minutos.';

  @override
  String get followerWhitelistThreshold => 'Umbral de seguidores';

  @override
  String get followerWhitelistStart => 'Comprobar y añadir';

  @override
  String followerWhitelistProgress(String arg0, String arg1) {
    return 'Perfiles comprobados: $arg0 de $arg1';
  }

  @override
  String followerWhitelistResult(String arg0, String arg1) {
    return 'Añadidos a la lista blanca: $arg0. Recuento no disponible: $arg1.';
  }

  @override
  String get followerWhitelistRateLimited =>
      'Instagram limitó las solicitudes. La comprobación se detuvo y guardó las coincidencias encontradas.';

  @override
  String get sortDateDescendingLong =>
      'Fecha descendente (más recientes primero)';

  @override
  String get sortDateAscendingLong => 'Fecha ascendente (más antiguos primero)';

  @override
  String get sortAlphabeticalAscending => 'Alfabético (A–Z)';

  @override
  String get sortAlphabeticalDescending => 'Alfabético (Z–A)';

  @override
  String get cannotSavePreference => 'No se pudo guardar la preferencia';

  @override
  String initializationError(String arg0) {
    return 'Error de inicialización: $arg0';
  }

  @override
  String deleteDataError(String arg0) {
    return 'No se pudieron eliminar los datos: $arg0';
  }

  @override
  String loadFilesError(String arg0) {
    return 'No se pudieron cargar los archivos: $arg0';
  }

  @override
  String loadArchiveError(String arg0) {
    return 'No se pudo cargar el archivo ZIP: $arg0';
  }

  @override
  String saveWhitelistError(String arg0) {
    return 'No se pudo guardar la lista blanca: $arg0';
  }

  @override
  String get originalIcon => 'Instander claro';

  @override
  String get darkIcon => 'Instander oscuro';

  @override
  String get systemDefault => 'Predeterminado del sistema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get cannotOpenProfile => 'No se pudo abrir el perfil.';

  @override
  String get report => 'Informe';

  @override
  String get timeline => 'Cronología';

  @override
  String get whitelist => 'Lista blanca';

  @override
  String get settings => 'Ajustes';

  @override
  String get reportTitlePrefix => 'Quién ';

  @override
  String get reportTitleEmphasis => 'no te sigue';

  @override
  String get reportTitleSuffix => ' de vuelta';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Reintentar';

  @override
  String get followersFileLabel => 'seguidores';

  @override
  String get followingFileLabel => 'seguidos';

  @override
  String get missingFile => 'Falta un archivo';

  @override
  String loadMissingFile(String arg0) {
    return 'Cargar archivo\n$arg0';
  }

  @override
  String get orLoadZip => 'O cargar un archivo ZIP';

  @override
  String get allDone => '¡Todo listo!';

  @override
  String get sortDateDescending => 'Fecha descendente';

  @override
  String get sortDateAscending => 'Fecha ascendente';

  @override
  String get newestFirst => '(Más recientes primero)';

  @override
  String get oldestFirst => '(Más antiguos primero)';

  @override
  String get newest => 'Más recientes';

  @override
  String get oldest => 'Más antiguos';

  @override
  String get nameAscending => 'Nombre A–Z';

  @override
  String get nameDescending => 'Nombre Z–A';

  @override
  String selectFilesError(String arg0) {
    return 'No se pudieron seleccionar los archivos: $arg0';
  }

  @override
  String selectArchiveError(String arg0) {
    return 'No se pudo seleccionar el archivo ZIP: $arg0';
  }

  @override
  String get exportDateHelp =>
      'Fecha de exportación de Instagram (no de cada seguimiento)';

  @override
  String get cancel => 'Cancelar';

  @override
  String get importAction => 'Importar';

  @override
  String get everyoneFollowsBack => '¡Todos te siguen de vuelta! 🎉';

  @override
  String get noProfilesToReview => 'No hay perfiles pendientes de revisar.';

  @override
  String get onboardingStep1of5 => 'PASO 1 DE 5';

  @override
  String get privateReportTitle => 'Tu informe, privado.';

  @override
  String get privateReportDescription =>
      'InstaLander compara tus seguidores con las cuentas que sigues para mostrarte quién no te sigue de vuelta. Todo se procesa en tu dispositivo: no necesitas iniciar sesión en Instagram ni compartir tu contraseña.';

  @override
  String get onboardingStep2of5 => 'PASO 2 DE 5';

  @override
  String get loadReportTitle => 'Carga y consulta tu informe';

  @override
  String get loadReportDescription =>
      'Carga los archivos JSON de seguidores y seguidos, o el ZIP que los contiene, y selecciona la fecha de exportación si es necesario. El Informe muestra las cuentas que no te siguen de vuelta: puedes ordenarlas y abrir sus perfiles de Instagram. Para obtener ayuda con los archivos, toca «Cómo exportar tu información de Instagram».';

  @override
  String get onboardingStep3of5 => 'PASO 3 DE 5';

  @override
  String get chooseWhitelistTitle =>
      'Elige a quién mantener en tu lista blanca';

  @override
  String get chooseWhitelistDescription =>
      '¿Quieres seguir a alguien que no te sigue de vuelta? Añádelo a tu lista blanca para excluirlo del Informe. En la pestaña Lista blanca puedes buscar los perfiles guardados y eliminarlos cuando quieras.';

  @override
  String get onboardingStep4of5 => 'PASO 4 DE 5';

  @override
  String get timelineIntroTitle => 'Consulta los cambios en la cronología';

  @override
  String get timelineIntroDescription =>
      'Al cargar una nueva lista de seguidores, la app conserva la anterior y las compara. La Cronología muestra quién ya no aparece entre tus seguidores entre dos exportaciones, sin indicar una fecha exacta en la que dejó de seguirte.';

  @override
  String get onboardingStep5of5 => 'PASO 5 DE 5';

  @override
  String get reminderIntroTitle => 'Recuerda actualizar tus datos';

  @override
  String get reminderIntroDescription =>
      'Tu informe se actualiza al importar archivos nuevos. En Ajustes puedes activar un recordatorio cada mes, cada 3 meses o cada 6 meses para solicitar otra exportación. La notificación es local y funciona sin mantener abierta la app.';

  @override
  String get exportStep1of6 => 'PASO 1 DE 6';

  @override
  String get accountsCenterTitle => 'Abre el Centro de cuentas';

  @override
  String get accountsCenterDescription =>
      'Abre Instagram, ve a tu perfil y toca el menú ≡ de la parte superior. Abre el Centro de cuentas.';

  @override
  String get exportStep2of6 => 'PASO 2 DE 6';

  @override
  String get requestDataTitle => 'Solicita una copia de tus datos';

  @override
  String get requestDataDescription =>
      'Abre «Tu información y permisos» y elige «Exportar tu información» y después «Crear exportación». Selecciona tu cuenta de Instagram.';

  @override
  String get exportStep3of6 => 'PASO 3 DE 6';

  @override
  String get chooseJsonTitle => 'Elige el formato JSON';

  @override
  String get chooseJsonDescription =>
      'En las opciones de exportación, elige el formato JSON y envía la solicitud.';

  @override
  String get exportStep4of6 => 'PASO 4 DE 6';

  @override
  String get exportDateRangeTitle =>
      'Elige «Desde el principio» como intervalo';

  @override
  String get exportDateRangeDescription =>
      'Selecciona «Exportar al dispositivo». En las opciones de exportación, abre «Intervalo de fechas» y selecciona «Desde el principio». Así se incluyen las listas completas de seguidores y cuentas seguidas.';

  @override
  String get downloadArchiveTitle => 'Descarga y extrae el archivo';

  @override
  String get downloadArchiveDescription =>
      'Cuando Instagram te avise de que la exportación está lista, descarga el ZIP. Cárgalo directamente en la app o extráelo y selecciona todos los archivos followers_*.json y following_*.json, normalmente en la carpeta followers_and_following.';

  @override
  String saveOnboardingError(String arg0) {
    return 'No se pudo guardar la finalización: $arg0';
  }

  @override
  String get back => 'Atrás';

  @override
  String get backToReport => 'Volver al informe';

  @override
  String get startApp => 'Continuar a la app';

  @override
  String get next => 'Siguiente';

  @override
  String get oneTapToDeveloper =>
      'Un toque más para activar el modo de desarrollador';

  @override
  String tapsToDeveloper(String arg0) {
    return '$arg0 toques más para activar el modo de desarrollador';
  }

  @override
  String get enablingDeveloper => 'Activando el modo de desarrollador…';

  @override
  String get developerEnabled => 'Modo de desarrollador activado';

  @override
  String get developerEnableError =>
      'No se pudo activar el modo de desarrollador. Inténtalo de nuevo.';

  @override
  String get appearance => 'Apariencia';

  @override
  String get materialThemeDescription => 'Diseño y componentes de Material 3';

  @override
  String get oneUiThemeDescription =>
      'Interfaz One UI con navegación en forma de píldora';

  @override
  String get brightness => 'Tema claro u oscuro';

  @override
  String get brightnessDescription =>
      'Elige un tema fijo o sigue el del dispositivo.';

  @override
  String get system => 'Sistema';

  @override
  String get appIcon => 'Icono de la app';

  @override
  String get lightIcon => 'Instander claro';

  @override
  String get lightIconDescription => 'Una cara familiar.';

  @override
  String get darkIconTitle => 'Instander oscuro';

  @override
  String get darkIconDescription => 'Black is the new black';

  @override
  String get behavior => 'Comportamiento';

  @override
  String get openProfilesInBrowser => 'Abrir perfiles en el navegador';

  @override
  String get showProfilePhotos => 'Mostrar fotos de perfil';

  @override
  String get showProfilePhotosDescription =>
      'Busca fotos en las páginas públicas de Instagram. Si no hay foto disponible, muestra las iniciales.';

  @override
  String get openBrowserDescription =>
      'Usa el navegador predeterminado del dispositivo.';

  @override
  String get openInstagramDescription =>
      'Usa la app de Instagram o el navegador si no está instalada.';

  @override
  String get savePreferenceError => 'No se pudo guardar la preferencia.';

  @override
  String get autoWhitelist => 'Lista blanca automática al importar';

  @override
  String get autoWhitelistDescription =>
      'Desde la segunda exportación de seguidores, añade las cuentas que ya seguías y que nunca han aparecido entre tus seguidores importados. Las cuentas que dejan de seguirte permanecen en el Informe.';

  @override
  String get followerTrackingNotifications => 'Notificaciones';

  @override
  String get followerTrackingAutomatic => 'Comprobación automática';

  @override
  String get followerTrackingDescription =>
      'Comprueba el número de seguidores al activarlo y luego una vez al día. Recibirás un aviso si el número cambia. Si desactivas esta opción, la app no se ejecuta en segundo plano para comprobar los seguidores.';

  @override
  String get followerTrackingChooseProfile =>
      'Añade un perfil para activar el seguimiento.';

  @override
  String get followerTrackingAdd => 'Añadir perfil seguido';

  @override
  String get followerTrackingEdit => 'Editar perfil seguido';

  @override
  String get followerTrackingRemove => 'Quitar perfil seguido';

  @override
  String get followerTrackingUsername => 'Nombre de usuario de Instagram';

  @override
  String get followerTrackingInvalidUsername =>
      'Introduce un nombre de usuario de Instagram válido.';

  @override
  String get followerTrackingSave => 'Guardar';

  @override
  String get followerTrackingUnavailable =>
      'No se pudo activar el seguimiento. Comprueba que las notificaciones estén permitidas en los ajustes de Android.';

  @override
  String get followerTrackingError =>
      'No se pudieron actualizar los ajustes de seguimiento.';

  @override
  String get instagramReminder => 'Recordatorio de Instagram';

  @override
  String get reminderDescription =>
      'Recuerda solicitar una descarga de tu información. Notificación local; no hace falta mantener la app abierta.';

  @override
  String get androidOnly => 'Disponible en la app para Android.';

  @override
  String get allowReminderNotifications =>
      'Permite las notificaciones en los ajustes del sistema para activar los recordatorios.';

  @override
  String setReminderError(String arg0) {
    return 'No se pudo configurar el recordatorio: $arg0';
  }

  @override
  String saveReminderFrequencyError(String arg0) {
    return 'No se pudo guardar la frecuencia: $arg0';
  }

  @override
  String get about => 'Información';

  @override
  String get version => 'Versión';

  @override
  String get project => 'Proyecto';

  @override
  String get advertisingPrivacy => 'Privacidad publicitaria';

  @override
  String get manageConsent => 'Gestionar las preferencias de consentimiento';

  @override
  String get noConsentOptions =>
      'Las opciones de consentimiento publicitario no están disponibles en este momento.';

  @override
  String get cannotOpenRepository => 'No se pudo abrir el repositorio';

  @override
  String get testNotificationScheduled => 'Notificación de prueba programada.';

  @override
  String get testNotificationSent => 'Notificación de prueba enviada.';

  @override
  String get allowTestNotifications =>
      'Permite las notificaciones de InstaLander en los ajustes del sistema.';

  @override
  String get testNotificationError =>
      'No se pudo enviar o programar la notificación de prueba.';

  @override
  String testDataAdded(String arg0) {
    return 'Datos de prueba añadidos: $arg0';
  }

  @override
  String get buildMode => 'Modo de compilación';

  @override
  String get debugDataDescription =>
      'Genera perfiles aleatorios con el prefijo debug_. Los datos de prueba son temporales: desaparecen al reiniciar o importar nuevos JSON. Se conservan los datos importados.';

  @override
  String get advertising => 'Publicidad';

  @override
  String get advertisingDescription =>
      'Mostrar anuncios tras obtener el consentimiento necesario.';

  @override
  String get populateTimeline => 'Rellenar la cronología';

  @override
  String get populateTimelineDescription =>
      'Añadir intervalos y bajas de seguidores de ejemplo';

  @override
  String get populateWhitelist => 'Rellenar la lista blanca';

  @override
  String get populateWhitelistDescription =>
      'Añadir perfiles de ejemplo a la lista blanca';

  @override
  String get populateReport => 'Rellenar el informe';

  @override
  String get populateReportDescription =>
      'Generar seguidores y seguidos aleatorios';

  @override
  String get sendTestNotification => 'Enviar una notificación de prueba';

  @override
  String get sendTestNotificationDescription =>
      'Mostrar una notificación ahora en el dispositivo';

  @override
  String get scheduleTestNotification => 'Programar una notificación de prueba';

  @override
  String get scheduleTestNotificationDescription =>
      'Elegir el tiempo de espera';

  @override
  String get clearAllData => 'Borrar todos los datos';

  @override
  String get clearAllDataDescription =>
      'Eliminar archivos importados, cronología, lista blanca, recordatorios y preferencias';

  @override
  String changeIconError(String arg0) {
    return 'No se pudo cambiar el icono: $arg0';
  }

  @override
  String get clearAllDataTitle => '¿Borrar todos los datos?';

  @override
  String get clearAllDataConfirmation =>
      'Se eliminarán los archivos importados, la cronología, el recordatorio, la lista blanca, los perfiles revisados y las preferencias. Esta acción no se puede deshacer.';

  @override
  String get clearEverything => 'Borrar todo';

  @override
  String clearAllDataError(String arg0) {
    return 'No se pudieron borrar los datos: $arg0';
  }

  @override
  String get timelineDescription =>
      'La Timeline compara dos exportaciones de seguidores y muestra los cambios del intervalo, sin indicar el momento exacto en que alguien dejó de seguirte.\n\nLa etiqueta verde indica nuevos seguidores y la roja, perfiles que ya no aparecen. Los recuentos suman primero los nuevos y restan después los perdidos. El total intermedio explica el saldo; no es una medición en un momento concreto.\n\nLos cambios de nombre confirmados no cuentan como seguidores nuevos ni perdidos. Un perfil que tampoco aparece en una lista actualizada de seguidos podría haber sido eliminado.\n\nEn “Archivos importados” puedes ver y eliminar importaciones. El Informe y la Timeline se recalculan con los archivos restantes.';

  @override
  String get populateProfileChanges => 'Añadir cambios de perfil de prueba';

  @override
  String get populateProfileChangesDescription =>
      'Añade a la cronología perfiles renombrados y posiblemente eliminados';

  @override
  String get timelineRenamed => 'Nombre de usuario cambiado';

  @override
  String get timelinePossiblyDeleted => 'Posible eliminación';

  @override
  String timelinePreviousUsername(String arg0) {
    return 'Antes: $arg0';
  }

  @override
  String get timelineEmpty =>
      'Carga dos exportaciones de seguidores para iniciar la cronología.';

  @override
  String get noUnfollows => 'Nadie ha dejado de seguirte';

  @override
  String get oneLostFollower => '1 perfil ya no te sigue';

  @override
  String lostFollowers(String arg0) {
    return '$arg0 perfiles ya no te siguen';
  }

  @override
  String get exportComparison => 'Comparación de exportaciones';

  @override
  String get estimatedDate =>
      'Fecha inicial estimada a partir del antiguo archivo JSON.';

  @override
  String dateInterval(String arg0, String arg1) {
    return 'Del $arg0 al $arg1';
  }

  @override
  String get from => 'del';

  @override
  String get to => 'al';

  @override
  String get whitelistCountLabel => 'Perfiles en la lista blanca:';

  @override
  String get whitelistCountSemantics => 'Perfiles en la lista blanca';

  @override
  String get listView => 'Lista';

  @override
  String get gridView => 'Cuadrícula';

  @override
  String get clearWhitelist => 'Vaciar la lista blanca';

  @override
  String get searchProfile => 'Buscar perfiles';

  @override
  String get clearSearch => 'Borrar búsqueda';

  @override
  String get noProfilesFound => 'No se encontraron perfiles';

  @override
  String get emptyWhitelist => 'Tu lista blanca está vacía';

  @override
  String get emptyWhitelistDescription =>
      'Añade perfiles a tu lista blanca para excluirlos\nde la lista de quienes no te siguen.\n\nPuedes añadirlos desde el Informe\ntocando el corazón\nen la tarjeta de un perfil.';

  @override
  String get openProfile => 'Abrir perfil';

  @override
  String get removeFromWhitelist => 'Eliminar de la lista blanca';

  @override
  String get remove => 'Eliminar';

  @override
  String get excludedFromReport => 'Excluido del informe';

  @override
  String get openInstagramProfile => 'Abrir perfil de Instagram';

  @override
  String get clearWhitelistConfirmation =>
      '¿Quieres eliminar todos los perfiles de tu lista blanca? Esta acción no se puede deshacer.';

  @override
  String get clearWhitelistAction => 'Vaciar lista';

  @override
  String duplicateArchiveFile(String arg0) {
    return 'Nombre de archivo duplicado en el ZIP: $arg0';
  }

  @override
  String unreadableArchiveFile(String arg0) {
    return 'No se pudo leer $arg0 en el ZIP';
  }

  @override
  String get noArchiveFiles =>
      'No se encontraron archivos followers*.json ni following*.json en el ZIP';

  @override
  String get pickJsonTitle =>
      'Selecciona los JSON de Instagram (followers_*.json, following_*.json)';

  @override
  String get pickArchiveTitle => 'Selecciona el archivo ZIP de Instagram';

  @override
  String get selectValidFiles => 'Selecciona followers*.json o following*.json';

  @override
  String get chronologicalImportError =>
      'La fecha debe ser igual o posterior a la de la última importación.';

  @override
  String get invalidProfileMatch =>
      'Coincidencia de perfiles no válida o duplicada.';

  @override
  String invalidInstagramFormat(String arg0) {
    return 'Formato de Instagram no válido: $arg0';
  }

  @override
  String unrecognizedProfiles(String arg0) {
    return 'No se reconocieron perfiles en $arg0';
  }

  @override
  String get notificationDelay => 'Tiempo de espera';

  @override
  String get invalidNotificationDelay =>
      'Introduce un tiempo de espera positivo válido.';

  @override
  String get timeUnit => 'Unidad de tiempo';

  @override
  String get milliseconds => 'Milisegundos';

  @override
  String get seconds => 'Segundos';

  @override
  String get minutes => 'Minutos';

  @override
  String get hours => 'Horas';

  @override
  String get days => 'Días';

  @override
  String get notificationDelayDescription =>
      'Se admiten valores decimales. Una nueva programación sustituye a la notificación de prueba anterior. Android puede retrasar la entrega para ahorrar batería.';

  @override
  String get schedule => 'Programar';

  @override
  String get ghostProfilesTitle => 'Posibles perfiles «fantasma»';

  @override
  String get ghostProfilesDescription =>
      'Las exportaciones JSON de Instagram pueden contener perfiles «fantasma»: cuentas que ya no sigues o que se han eliminado.\n\nEstas incoherencias proceden de los datos de Instagram, no de un error de la app. InstaLander procesa la información de los archivos que cargas.';

  @override
  String get gotIt => 'Entendido';

  @override
  String get ad => 'Anuncio';

  @override
  String get adUnavailable => 'Anuncio no disponible';

  @override
  String get everyMonth => 'Cada mes';

  @override
  String get everyThreeMonths => 'Cada 3 meses';

  @override
  String get everySixMonths => 'Cada 6 meses';

  @override
  String get required => 'Obligatorio';

  @override
  String get setUpReport => 'Configura tu informe';

  @override
  String get setUpReportDescription =>
      'Para empezar, añade los archivos JSON de Instagram con tus seguidores y las cuentas que sigues.';

  @override
  String get requiredFiles => 'ARCHIVOS NECESARIOS';

  @override
  String get standardJson => 'Formato JSON estándar';

  @override
  String get exportGuide => 'Cómo exportar tu información de Instagram';

  @override
  String get loadJson => 'Cargar JSON';

  @override
  String get loadZip => 'Cargar archivo ZIP';

  @override
  String get reviewCountLabel => 'Por revisar:';

  @override
  String get reviewCountSemantics => 'Perfiles por revisar';

  @override
  String get possibleUsernameChanges => 'Posibles cambios de nombre de usuario';

  @override
  String get usernameChangesDescription =>
      'Estos perfiles tienen la misma fecha y hora de inicio del seguimiento. Podrían ser la misma persona, pero no es seguro. Selecciona solo las coincidencias que reconozcas; el resto se mantendrá por separado.';

  @override
  String followDate(String arg0) {
    return 'Seguido: $arg0';
  }

  @override
  String get newUsername => 'Nuevo nombre de usuario';

  @override
  String get noMatch => 'No vincular';

  @override
  String get cancelImport => 'Cancelar importación';

  @override
  String get ignoreAll => 'Ignorar todo';

  @override
  String get confirmImport => 'Confirmar e importar';

  @override
  String get unknownDate => 'Fecha desconocida';

  @override
  String get profileDetails => 'Detalles del perfil';

  @override
  String get followedOn => 'Seguido el';

  @override
  String get doesNotFollowBack => 'No te sigue de vuelta';

  @override
  String get dragToSelect =>
      'Desliza el dedo sobre una acción para seleccionarla';

  @override
  String get manageWhitelist => '📋 Gestionar lista blanca';

  @override
  String get yourWhitelist => 'Tu lista blanca';

  @override
  String get whitelistIsEmpty => 'La lista blanca está vacía.';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Sistema (automático)';

  @override
  String get languageDescription =>
      'Elige el idioma de la app o sigue el del teléfono.';

  @override
  String missingFileDescription(String arg0, String arg1, String arg2) {
    return 'Hemos encontrado el archivo $arg0. Para crear el informe, carga también $arg1 ($arg2).';
  }

  @override
  String removeWhitelistConfirmation(String arg0) {
    return '¿Eliminar a \"$arg0\" de la lista blanca?\nVolverá a aparecer en la lista de quienes no te siguen.';
  }

  @override
  String get hideDebug => 'Ocultar opciones de depuración';

  @override
  String get hideDebugDescription =>
      'Puedes volver a mostrarlas tocando la versión 10 veces.';

  @override
  String get debugHidden => 'Opciones de depuración ocultas.';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get privacyPolicyDescription =>
      'Cómo se utilizan y conservan los datos';

  @override
  String get cannotOpenPrivacyPolicy =>
      'No se pudo abrir la política de privacidad.';

  @override
  String get whiteIcon => 'Smiley face claro';

  @override
  String get whiteIconDescription => 'Sonreír sienta bien.';

  @override
  String get glowDarkIcon => 'Smiley face oscuro';

  @override
  String get glowDarkIconDescription => 'Pásate al lado oscuro.';

  @override
  String get exportStep5of6 => 'PASO 5 DE 6';

  @override
  String get exportStep6of6 => 'PASO 6 DE 6';

  @override
  String get selectFollowDataTitle => 'Selecciona solo seguidores y seguidos';

  @override
  String get selectFollowDataDescription =>
      'Desmarca todas las categorías y selecciona solo la de seguidores y seguidos. No necesitas mensajes, fotos, vídeos ni otra información: InstaLander solo utiliza estas listas para crear tu informe.';

  @override
  String get skip => 'Omitir';
}
