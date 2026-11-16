import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum AppLocale { es, en }

extension AppLocaleContext on BuildContext {
  AppStrings get t =>
      Localizations.of<AppStrings>(this, AppStrings) ??
      AppStrings(AppLocale.es);
}

/// Textos de la app. Nada de intl: es un mapa simple por si mas adelante
/// se quiere migrar a arb, pero para dos idiomas esto basta y sobra.
class AppStrings {
  const AppStrings(this.locale);

  final AppLocale locale;

  static const _es = <String, String>{
    'app_title': 'Pendientes',
    'brand': 'Pendientes',
    'sound_on': 'SND ON',
    'sound_off': 'SND OFF',
    'display_ready': 'todo listo',
    'display_one_pending': 'cosa por hacer',
    'display_many_pending': 'cosas por hacer',
    'done_of_total': '{done} / {total} hechas',
    'add_placeholder': 'nueva tarea...',
    'add_button': 'Añadir',
    'search_placeholder': 'buscar...',
    'search_tabs_placeholder': 'buscar pestaña...',
    'search_tabs_empty': 'sin pestañas con ese nombre',
    'no_tabs_title': 'sin pestañas',
    'no_tabs_subtitle': 'crea una desde configuración',
    'no_tabs_open_settings': 'ABRIR CONFIGURACIÓN',
    'all_tab': 'Todas',
    'log_label': 'Registro',
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
        'mantener presionado 5 segundos y confirmar con un toque más. '
        'una tarea puede pertenecer a varias pestañas a la vez: mantenla '
        'presionada para elegir cuáles. eliminar una pestaña no borra sus '
        'tareas, solo las desliga.',
    'settings_new_tab_placeholder': 'nueva pestaña',
    'settings_hold_create': 'MANTÉN P/ CREAR',
    'settings_hold_delete': 'MANTÉN P/ BORRAR',
    'settings_hold_confirm': 'TOCA PARA CONFIRMAR',
    'settings_only_tab': 'ÚLTIMA PESTAÑA',
    'settings_export': 'EXPORTAR',
    'settings_export_hint':
        'los [x] son las marcadas y los [ ] las pendientes. '
        'cada ## declara una pestaña, y {nombre, nombre2} antes del '
        'texto liga esa tarea a una o varias.',
    'settings_copy': 'COPIAR',
    'settings_import': 'IMPORTAR',
    'settings_import_hint':
        'se agrega a "{tab}" sin borrar lo que ya tienes. usa "## nombre" '
        'para declarar pestañas y "{nombre, nombre2}" antes del texto '
        'para ligar una tarea a varias.',
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
    'task_tabs_title': 'pestañas ligadas',
    'cancel': 'cancelar',
    'missions_title': 'MISIONES',
    'missions_entry': 'Misiones',
    'missions_entry_none': 'agrupa tareas y complétalas todas',
    'missions_entry_summary': '{active} activas · {done} completadas',
    'missions_new': 'NUEVA MISIÓN',
    'missions_empty_title': 'sin misiones',
    'missions_empty_subtitle':
        'una misión agrupa varias tareas: cuando las completas todas, '
        'se cumple la misión.',
    'mission_progress': '{done} / {total} tareas',
    'mission_done_badge': 'COMPLETADA',
    'mission_editor_new': 'NUEVA MISIÓN',
    'mission_editor_edit': 'EDITAR MISIÓN',
    'mission_title_label': 'TÍTULO',
    'mission_title_placeholder': 'ej. semana de exámenes',
    'mission_desc_label': 'LO QUE SE HARÁ',
    'mission_desc_placeholder': 'describe el objetivo de la misión...',
    'mission_tasks_label': 'TAREAS DE LA MISIÓN',
    'mission_tasks_count': '{count} elegidas',
    'mission_tasks_search': 'buscar tarea...',
    'mission_no_tasks': 'todavía no tienes tareas: crea algunas primero.',
    'mission_save': 'GUARDAR',
    'mission_hold_delete': 'MANTÉN P/ BORRAR',
    'msg_mission_needs_title': 'ponle un título a la misión',
    'msg_mission_needs_tasks': 'elige al menos una tarea',
    'mission_complete_title': '¡MISIÓN COMPLETADA!',
    'mission_complete_tasks': '{count} tareas cumplidas',
    'mission_complete_tap': 'toca para continuar',
  };

  static const _en = <String, String>{
    'app_title': 'Tasks',
    'brand': 'Tasks',
    'sound_on': 'SND ON',
    'sound_off': 'SND OFF',
    'display_ready': 'all done',
    'display_one_pending': 'task left',
    'display_many_pending': 'tasks left',
    'done_of_total': '{done} / {total} done',
    'add_placeholder': 'new task...',
    'add_button': 'Add',
    'search_placeholder': 'search...',
    'search_tabs_placeholder': 'search tab...',
    'search_tabs_empty': 'no tabs match',
    'no_tabs_title': 'no tabs',
    'no_tabs_subtitle': 'create one from settings',
    'no_tabs_open_settings': 'OPEN SETTINGS',
    'all_tab': 'All',
    'log_label': 'Log',
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
        'hold plus one more tap to confirm. a task can belong to several '
        'tabs at once: hold it to pick which ones. deleting a tab does '
        'not delete its tasks, it only unlinks them.',
    'settings_new_tab_placeholder': 'new tab',
    'settings_hold_create': 'HOLD TO CREATE',
    'settings_hold_delete': 'HOLD TO DELETE',
    'settings_hold_confirm': 'TAP TO CONFIRM',
    'settings_only_tab': 'LAST TAB',
    'settings_export': 'EXPORT',
    'settings_export_hint':
        '[x] are marked, [ ] are pending. each ## declares a tab, and '
        '{name, name2} before the text links that task to one or more.',
    'settings_copy': 'COPY',
    'settings_import': 'IMPORT',
    'settings_import_hint':
        'gets added to "{tab}" without deleting what you already have. '
        'use "## name" to declare tabs and "{name, name2}" before the '
        'text to link a task to several.',
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
    'task_tabs_title': 'linked tabs',
    'cancel': 'cancel',
    'missions_title': 'MISSIONS',
    'missions_entry': 'Missions',
    'missions_entry_none': 'group tasks and finish them all',
    'missions_entry_summary': '{active} active · {done} complete',
    'missions_new': 'NEW MISSION',
    'missions_empty_title': 'no missions',
    'missions_empty_subtitle':
        'a mission groups several tasks: finish them all and the '
        'mission is complete.',
    'mission_progress': '{done} / {total} tasks',
    'mission_done_badge': 'COMPLETE',
    'mission_editor_new': 'NEW MISSION',
    'mission_editor_edit': 'EDIT MISSION',
    'mission_title_label': 'TITLE',
    'mission_title_placeholder': 'e.g. exam week',
    'mission_desc_label': 'WHAT WILL BE DONE',
    'mission_desc_placeholder': 'describe the goal of the mission...',
    'mission_tasks_label': 'MISSION TASKS',
    'mission_tasks_count': '{count} selected',
    'mission_tasks_search': 'search task...',
    'mission_no_tasks': 'you have no tasks yet: create some first.',
    'mission_save': 'SAVE',
    'mission_hold_delete': 'HOLD TO DELETE',
    'msg_mission_needs_title': 'give the mission a title',
    'msg_mission_needs_tasks': 'pick at least one task',
    'mission_complete_title': 'MISSION COMPLETE!',
    'mission_complete_tasks': '{count} tasks done',
    'mission_complete_tap': 'tap to continue',
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
  bool shouldReload(covariant AppStringsDelegate old) => old.locale != locale;
}
