import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({Key? key}) : super(key: key);

  @override
  _LanguagePageState createState() => _LanguagePageState();
}

// ESTA LÍNEA ESTÁ LIMPIA (YA NO TIENE 'with AutomaticKeepAliveClientMixin')
class _LanguagePageState extends State<LanguagePage> {
  
  // ESTA LÍNEA NO ES NECESARIA (se borró)
  // @override bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // ESTA LÍNEA YA NO ES NECESARIA (se borró)
    // super.build(context);

    return ListView(
      // Padding en la parte de abajo para la barra flotante
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
      children: [
        Text(
          'lang_page_title'.tr(),
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ListTile(
          title: Text('lang_spanish'.tr()),
          leading: const Text('🇪🇸', style: TextStyle(fontSize: 24)),
          onTap: () {
            // Cambia el idioma de la app
            context.setLocale(const Locale('es'));
          },
          // Marca el idioma actual
          selected: context.locale == const Locale('es'),
          selectedTileColor: Colors.blue.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        ListTile(
          title: Text('lang_english'.tr()),
          leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
          onTap: () {
            // Cambia el idioma de la app
            context.setLocale(const Locale('en'));
          },
          // Marca el idioma actual
          selected: context.locale == const Locale('en'),
          selectedTileColor: Colors.blue.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ],
    );
  }
}