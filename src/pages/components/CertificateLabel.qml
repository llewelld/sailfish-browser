/****************************************************************************
**
** Copyright (C) 2019 Jolla Ltd.
** Contact: David Llewellyn-jones <david.llewellyn-jones@jolla.com>
**
****************************************************************************/

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

import QtQuick 2.2
import Sailfish.Silica 1.0

Item {
    property alias key: keyLabel.text
    property alias value: valueLabel.text
    property bool danger
    property bool happy
    property int tabPos: (key !== "") ? Theme.itemSizeExtraLarge : 0
    readonly property real _valueWidth: width - tabPos - valueLabel.anchors.leftMargin
    visible: value && value.length > 0
    height: Math.max(keyLabel.height, valueLabel.height)
    width: parent.width - 2 * Theme.horizontalPageMargin
    x: Theme.horizontalPageMargin

    Label {
        id: keyLabel
        width: tabPos
        wrapMode: Text.Wrap
        color: Theme.highlightColor
    }
    Label {
        id: valueLabel
        width: _valueWidth
        anchors {
            top: keyLabel.top
            left: keyLabel.right
            leftMargin: tabPos > 0 ? Theme.paddingSmall : 0
        }
        wrapMode: Text.Wrap
        color: danger ? Theme.errorColor : happy ? (palette.colorScheme === Theme.LightOnDark ? "#22ff22" : "#007700") : Theme.secondaryHighlightColor
        opacity: danger ? Theme.opacityHigh : 1.0
    }
}
