import 'package:dashboard/load.dart';
import 'package:flutter/cupertino.dart';
import 'manager.dart';

class AppButton extends StatelessWidget {
  final Widget image;
  final Widget title;
  final String id;

  const AppButton({Key key, this.image, this.title, this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      child: Column(
        children: <Widget>[
          image,
          title,
        ],
      ),
      onPressed: () async {
        loadId(id);
        Manager()
            .writeShared('list', await Manager().readShared('list') + ';' + id);
        eventBus.fire('closeMenu');
      },
    );
  }
}
