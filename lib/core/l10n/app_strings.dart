import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum AppLocale { es, en }

extension AppLocaleContext on BuildContext {
  AppStrings get t => Localizations.of<AppStrings>(this, AppStrings) ??
      AppStrings(AppLocale.es);
}

/// Textos de la app. Nada de intl: es un mapa simple por si mas adelante
/// se quiere migrar a arb, pero para dos idiomas esto basta y sobra.
class AppStrings {
  const AppStrings(this.locale);

  final AppLocale locale;

  static const _es = <String, String>{
    'app_title': 'Pendientes',
    'brand': 'PENDIENTES',
    'sound_on': 'SND ON',
    'sound_off': 'SND OFF',
    'display_ready': 'todo listo',
    'display_one_pending': 'cosa por hacer',
    'display_many_pending': 'cosas por hacer',
    'done_of_total': '{done} / {total} hechas',
    'add_placeholder': 'nueva tarea...',
    'add_button': 'AÑADIR',
    'search_placeholder': 'buscar...',
    'search_tabs_placeholder': 'buscar pestaña...',
    'search_tabs_empty': 'sin pestañas con ese nombre',
    'no_tabs_title': 'sin pestañas',
    'no_tabs_subtitle': 'crea una desde configuración',
    'no_tabs_open_settings': 'ABRIR CONFIGURACIÓN',
    'all_tab': 'TODAS',
    'log_label': 'REGISTRO',
    'log_of_label': '{visible} DE {total}',
    'empty_tab_title': 'pestaña vacía',
    'empty_tab_subtitle': 'sistema en reposo',
    'empty_search_title': 'sin coincidencias',
    'empty_search_subtitle': 'prueba con otra palabra',
    'settings_title': 'CONFIGURACIÓN',
    'settings_theme': 'TEMA',
    'settings_language': 'IDIOMA',
    'settings_tabs': 'PESTAÑAS',
    'settings_tabs_hint':
    'toca el nombre para editarlo. crear y eliminar necesitan '
        'mantener presionado 5 segundos y confirmar con un toque más.',
    'settings_new_tab_placeholder': 'nueva pestaña',
    'settings_hold_create': 'MANTÉN P/ CREAR',
    'settings_hold_delete': 'MANTÉN P/ BORRAR',
    'settings_hold_confirm': 'TOCA PARA CONFIRMAR',
    'settings_only_tab': 'ÚLTIMA PESTAÑA',
    'settings_export': 'EXPORTAR',
    'settings_export_hint':
    'los [x] son las marcadas y los [ ] las pendientes. '
        'cada ## abre una pestaña.',
    'settings_copy': 'COPIAR',
    'settings_import': 'IMPORTAR',
    'settings_import_hint':
    'se agrega a "{tab}" sin borrar lo que ya tienes. si el texto '
        'trae secciones "## nombre", cada una va a su pestaña.',
    'settings_import_hint_no_tab':
    'crea una pestaña primero para poder importar.',
    'settings_paste': 'PEGAR',
    'settings_hold_import': 'MANTÉN P/ IMPORTAR',
    'msg_tab_created': 'pestaña "{name}" creada',
    'msg_tab_renamed': 'renombrada a "{name}"',
    'msg_tab_deleted': 'pestaña "{name}" eliminada',
    'msg_tab_name_needed': 'escribe un nombre para la pestaña',
    'msg_copied': 'respaldo copiado al portapapeles',
    'msg_clipboard_empty': 'el portapapeles está vacío',
    'msg_pasted': 'texto pegado, mantén presionado para importar',
    'msg_backup_needed': 'pega primero un respaldo',
    'msg_imported': '{count} tareas agregadas a "{tab}"',
    'msg_import_invalid': 'el texto no tiene tareas válidas',
    'move_task_title': 'mover a',
    'move_task_here': 'ya está aquí',
    'move_task_done': 'movida a "{tab}"',
    'cancel': 'cancelar',
  };

  static const _en = <String, String>{
    'app_title': 'Tasks',
    'brand': 'TASKS',
    'sound_on': 'SND ON',
    'sound_off': 'SND OFF',
    'display_ready': 'all done',
    'display_one_pending': 'task left',
    'display_many_pending': 'tasks left',
    'done_of_total': '{done} / {total} done',
    'add_placeholder': 'new task...',
    'add_button': 'ADD',
    'search_placeholder': 'search...',
    'search_tabs_placeholder': 'search tab...',
    'search_tabs_empty': 'no tabs match',
    'no_tabs_title': 'no tabs',
    'no_tabs_subtitle': 'create one from settings',
    'no_tabs_open_settings': 'OPEN SETTINGS',
    'all_tab': 'ALL',
    'log_label': 'LOG',
    'log_of_label': '{visible} OF {total}',
    'empty_tab_title': 'empty tab',
    'empty_tab_subtitle': 'system idle',
    'empty_search_title': 'no matches',
    'empty_search_subtitle': 'try a different word',
    'settings_title': 'SETTINGS',
    'settings_theme': 'THEME',
    'settings_language': 'LANGUAGE',
    'settings_tabs': 'TABS',
    'settings_tabs_hint':
    'tap the name to edit it. creating and deleting need a 5 second '
        'hold plus one more tap to confirm.',
    'settings_new_tab_placeholder': 'new tab',
    'settings_hold_create': 'HOLD TO CREATE',
    'settings_hold_delete': 'HOLD TO DELETE',
    'settings_hold_confirm': 'TAP TO CONFIRM',
    'settings_only_tab': 'LAST TAB',
    'settings_export': 'EXPORT',
    'settings_export_hint':
    '[x] are marked, [ ] are pending. each ## opens a tab.',
    'settings_copy': 'COPY',
    'settings_import': 'IMPORT',
    'settings_import_hint':
    'gets added to "{tab}" without deleting what you already have. '
        'if the text has "## name" sections, each goes to its own tab.',
    'settings_import_hint_no_tab': 'create a tab first to be able to import.',
    'settings_paste': 'PASTE',
    'settings_hold_import': 'HOLD TO IMPORT',
    'msg_tab_created': '"{name}" tab created',
    'msg_tab_renamed': 'renamed to "{name}"',
    'msg_tab_deleted': '"{name}" tab deleted',
    'msg_tab_name_needed': 'type a name for the tab',
    'msg_copied': 'backup copied to clipboard',
    'msg_clipboard_empty': 'clipboard is empty',
    'msg_pasted': 'text pasted, hold to import',
    'msg_backup_needed': 'paste a backup first',
    'msg_imported': '{count} tasks added to "{tab}"',
    'msg_import_invalid': 'the text has no valid tasks',
    'move_task_title': 'move to',
    'move_task_here': 'already here',
    'move_task_done': 'moved to "{tab}"',
    'cancel': 'cancel',
  };

  Map<String, String> get _table => locale == AppLocale.es ? _es : _en;

  String t(String key, [Map<String, Object>? args]) {
    var text = _table[key] ?? key;
    args?.forEach((k, v) {
      text = text.replaceAll('{$k}', '$v');
    });
    return text;
  }
}

/// Delegate minimo para que Localizations.of funcione.
class AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const AppStringsDelegate(this.locale);

  final AppLocale locale;

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppStrings> load(Locale locale) async => AppStrings(this.locale);

  @override
  bool shouldReload(covariant AppStringsDelegate old) =>
      old.locale != locale;
}