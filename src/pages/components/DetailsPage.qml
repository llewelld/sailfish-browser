import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: root

    property string title
    property var details

    function octetSequence(d) {
        return /^(?:[0-9a-f]{2}:)+(?:[0-9a-f]{2})$/.test(d)
    }

    function formatOctetSequence(d) {
        // Wrap every 10 octets
        for (var i = 29; i < d.length; i += 30) {
            d = d.substr(0, i) + '\n' + d.substr(i+1);
        }
        return d
    }

    Component.onCompleted: {
        var addProperty = function(group, name, octetSequence, value) {
            properties.append({ 'group': group, 'name': name, 'octetSequence': octetSequence, 'value': value })
        }

        addProperty('', 'Version', false, details['Version'])
        addProperty('', 'SerialNumber', false, details['SerialNumber'])

        //% "Subject"
        var groupName = qsTrId("settings_system-he-subject")
        var group = details['Subject']
        var name
        for (name in group) {
            addProperty(groupName, name, false, group[name])
        }

        //% "Validity"
        groupName = qsTrId("settings_system-he-validity")
        group = details['Validity']
        for (name in group) {
            var utcDate = new Date(group[name].getTime() + group[name].getTimezoneOffset() * 60000)
            addProperty(groupName, name, false, Format.formatDate(utcDate, Format.TimePoint))
        }

        //% "Issuer"
        groupName = qsTrId("settings_system-he-issuer")
        group = details['Issuer']
        for (name in group) {
            addProperty(groupName, name, false, group[name])
        }

        //% "Extensions"
        groupName = qsTrId("settings_system-he-extensions")
        group = details['Extensions']
        var os
        for (name in group) {
            os = octetSequence(group[name])
            addProperty(groupName, name, os, os ? formatOctetSequence(group[name]) : group[name])
        }

        //% "Public Key"
        groupName = qsTrId("settings_system-he-public_key")
        group = details['SubjectPublicKeyInfo']

        for (name in group) {
            os = octetSequence(group[name])
            addProperty(groupName, name, os, os ? formatOctetSequence(group[name]) : group[name])
        }

        //% "Signature"
        groupName = qsTrId("settings_system-he-signature")
        group = details['Signature']
        for (name in group) {
            os = octetSequence(group[name])
            addProperty(groupName, name, os, os ? formatOctetSequence(group[name]) : group[name])
        }
    }

    ListModel {
        id: properties
    }

    SilicaListView {
        anchors.fill: parent

        header: PageHeader {
            //% "Certificate details"
            title: qsTrId("settings_system-he-certificate_details")
        }

        model: properties

        section.property: 'group'
        section.criteria: ViewSection.FullString
        section.delegate: SectionHeader { text: section }

        delegate: Item {
            id: delegateItem
            width: ListView.view.width
            height: flow.height + Theme.paddingSmall*2

            Flow {
                id: flow

                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                y: Theme.paddingSmall

                Label {
                    width: implicitWidth + Theme.paddingMedium
                    text: name
                    color: Theme.highlightColor
                }
                Label {
                    text: value
                    wrapMode: Text.Wrap
                    color: Theme.secondaryHighlightColor
                    font.family: octetSequence ? 'Monospace' : Theme.fontFamily
                    font.pixelSize: octetSequence ? Theme.fontSizeExtraSmall : Theme.fontSizeMedium
                    opacity: octetSequence ? 0.7 : 1.0
                    onLineLaidOut: line.width = parent.width
                }
            }
        }

        VerticalScrollDecorator {}
    }
}
