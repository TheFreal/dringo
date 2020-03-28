import 'package:flutter/material.dart';

class NiceButton extends StatelessWidget {
  const NiceButton({
    Key key,
    @required bool loading,
    this.text,
    this.onPressed,
  })  : _loading = loading,
        super(key: key);

  final bool _loading;
  final String text;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(30.0),
          side: BorderSide(color: Colors.red)),
      color: Theme.of(context).primaryColor,
      onPressed: onPressed,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Center(
            child: (_loading
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : Text(
                    text,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  )),
          ),
        ),
      ),
    );
  }
}
