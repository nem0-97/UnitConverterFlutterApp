// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:unitconverter/category.dart';
import 'package:unitconverter/unit.dart';
import 'package:unitconverter/category_tile.dart';
import 'package:unitconverter/converter_route.dart';
import 'package:unitconverter/backdrop.dart';
import 'package:unitconverter/api.dart';

const _bgColor = Colors.purple;


class CategoryRoute extends StatefulWidget {
  final Color bgColor;

  const CategoryRoute({backgroundColor})
      : this.bgColor = backgroundColor ?? _bgColor;
  @override
  createState() => _CategoryRouteState();
}


class _CategoryRouteState extends State<CategoryRoute>{
  Category currCat;
  Category defaultCat;
  final cats = <Category>[];

  static const _baseColors = <Color>[
    Colors.teal,
    Colors.orange,
    Colors.pinkAccent,
    Colors.blueAccent,
    Colors.yellow,
    Colors.greenAccent,
    Colors.purpleAccent,
    Colors.red,
  ];

    /// Retrieves a list of [Categories] and their [Unit]s
  Future<void> _retrieveLocalCategories() async {
    // Consider omitting the types for local variables. For more details on Effective
    // Dart Usage, see https://www.dartlang.org/guides/language/effective-dart/usage
    final json = DefaultAssetBundle
        .of(context)
        .loadString('assets/data/regular_units.json');
    final data = JsonDecoder().convert(await json);
    if (data is! Map) {
      throw ('Data retrieved from API is not a Map');
    }
    var i=0;
    data.keys.forEach((key){
      var categ=Category(
        color: _baseColors[i],
        text: key,
        icon: 'assets/icons/'+key.toLowerCase().replaceAll(new RegExp(r'\s+\b|\b\s|\s'), '_')+'.png',
        units: data[key].map<Unit>((dynamic data) => Unit.fromJson(data)).toList(),
      );

      setState(() {
        if (i == 0) {defaultCat = categ;}
        cats.add(categ);
      });
      i++;
    });
  }

  //makes categories that require an API due to changing nature
  Future<void> _retrieveApiCategories() async {
    apiCats.forEach((cater){
      // Add a placeholder while we fetch the Currency category using the API or 
      setState(() {cats.add(Category(
          text: cater,
          units: [],
          color: _baseColors.last,
          icon: 'assets/icons/'+cater.toLowerCase().replaceAll(new RegExp(r'\s+\b|\b\s|\s'), '_')+'.png',
        ));
      });
    });

    apiCats.forEach((cater){
      //using await gave errors here saying to mark function body async even though it already was so used then
      //I think it is the foreach loop, should probably switch to standard for loop to use await probably
      API.getUnits(cater.toLowerCase().replaceAll(new RegExp(r'\s+\b|\b\s|\s'), '_')).then((jsonUnits){
      if (jsonUnits != null) {
        final units = <Unit>[];
        for (var unit in jsonUnits) {
          units.add(Unit.fromJson(unit));
        }
        setState(() {
          cats.removeWhere((el){return (el.text==cater);});
          cats.add(Category(
            text: cater,
            units: units,
            color: _baseColors.last,
            icon: 'assets/icons/'+cater.toLowerCase().replaceAll(new RegExp(r'\s+\b|\b\s|\s'), '_')+'.png',
          ));
        });
      }
      });
    });
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    if (cats.isEmpty) {
      await _retrieveLocalCategories();
      await _retrieveApiCategories();
    }
  }

  void _onCategoryTap(Category category) {
    setState(() {
      currCat = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (cats.isEmpty) {
      return Center(
        child: Container(
          height: 180.0,
          width: 180.0,
          child: CircularProgressIndicator(),
        ),
      );
    }

    assert(debugCheckHasMediaQuery(context));
    final listView = Padding(
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: 48.0,
      ),
      child: (MediaQuery.of(context).orientation == Orientation.portrait) ? ListView.builder(
        itemBuilder: (BuildContext context, int ind){return CategoryTile(cat:cats[ind],onTap: cats[ind].units.isEmpty ? null : _onCategoryTap,);},
        itemCount: cats.length,
      )
      : GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 3.0,
        children: cats.map((Category c) {
          return CategoryTile(
            cat: c,
            onTap: c.units.isEmpty ? null : _onCategoryTap,
          );
        }).toList(),
      ),
    );

    return Backdrop(
      currentCategory: currCat == null ? defaultCat : currCat,
      frontPanel: currCat == null? ConverterRoute(category: defaultCat) : ConverterRoute(category: currCat),
      backPanel: listView,
      frontTitle: Text('Unit Converter'),
      backTitle: Text('Select a Category'),
    );
  }
}