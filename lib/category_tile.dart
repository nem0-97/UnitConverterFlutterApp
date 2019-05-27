import 'package:flutter/material.dart';

import 'package:unitconverter/category.dart';

const _rowHeight = 100.0;

class CategoryTile extends StatelessWidget {
  final Category cat;
  final ValueChanged<Category> onTap;

  const CategoryTile({Key key, @required this.cat, @required this.onTap,})  : assert(cat != null), super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: _rowHeight,
        padding: EdgeInsets.all(8.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(_rowHeight / 2),
          splashColor: cat.color,
          highlightColor: cat.color,
          onTap: () => onTap(cat),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Image.asset(cat.icon),
              ),
              Center(
                child: Text(
                  cat.text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
