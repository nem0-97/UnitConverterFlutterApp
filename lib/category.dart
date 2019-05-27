// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'package:unitconverter/unit.dart';


class Category{
  final String text;
  final String icon;
  final ColorSwatch color;
  final List<Unit> units;

  const Category(
      {Key key, @required this.text, @required this.icon, @required this.color, @required this.units})
      : assert(text != null),
        assert(color != null),
        assert(icon != null),
        assert(units != null);
}
