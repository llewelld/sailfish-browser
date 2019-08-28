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
import Sailfish.Silica.private 1.0 as Private
import Sailfish.Browser 1.0
import Qt5Mozilla 1.0
import "." as Browser

SilicaFlickable {
    property QMozSecurity security
    readonly property bool _validCert: security && security.subjectDisplayName.length > 0
    visible: security
    contentHeight: Math.max(certInfoColumn.height + Theme.paddingMedium + showMoreSpacing.height, height)
    clip: contentHeight > height
    property real buttonHeight: Theme.itemSizeExtraSmall

    signal showCertDetail

    onSecurityChanged: {
        // Jump back to the top
        contentY = originY
    }

    VerticalScrollDecorator {}

    Column {
        id: certInfoColumn
        spacing: Theme.paddingSmall
        width: parent.width
        y: Theme.paddingMedium

        Label {
            width: parent.width - 2 * Theme.horizontalPageMargin
            x: Theme.horizontalPageMargin
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeLarge
            color: (security && security.allGood) ? (palette.colorScheme === Theme.LightOnDark ? "#22ff22" : "#007700") : Theme.errorColor
            text: {
                if (security && security.allGood) {
                    //: The SSL/TLS connection is good
                    //% "Connection is secure"
                    return qsTrId("sailfish_browser-la-cert_connection_secure")
                }
                //: Either no SSL/TLS is in use, or the SSL/TLS connection is broken in some way
                //% "Connection is not secure"
                return qsTrId("sailfish_browser-la-cert_connection_insecure")
            }
        }

        SectionHeader {
            //: Header separating out the main secuirty info from the details
            //% "Details"
            text: qsTrId("sailfish_browser-sh-cert_details")
        }

        CertificateLabel {
            value: {
                if (security) {
                    if (security.certIsNull) {
                        //% "The page does't offer any security"
                        return qsTrId("sailfish_browser-la-cert_none")
                    } else if (security.domainMismatch) {
                        //: The domain in the TLS certificate and the domain connected to are not the same
                        //% "The website doesn't match the name on the security certificate"
                        return qsTrId("sailfish_browser-la-cert_domain_mismatch")
                    } else if (security.notValidAtThisTime) {
                        //: The TLS certificate has expired or is not yet valid
                        //% "The security certificate has expired or isn't valid yet"
                        return qsTrId("sailfish_browser-la-cert_not_valid_at_this_time")
                    } else if (security.usesWeakCrypto) {
                        //: The TLS certificate is insecure because it uses weak encryption or hashing methods
                        //% "The conection only provides weak security"
                        return qsTrId("sailfish_browser-la-cert_weak_crypto")
                    } else if (security.loadedMixedActiveContent) {
                        //% "Parts of the page (e.g. scripts) are transmitted insecurely"
                        return qsTrId("sailfish_browser-la-cert_content_active_loaded")
                    } else if (security.loadedMixedDisplayContent) {
                        //% "Parts of the page (e.g. images) are transmitted insecurely"
                        return qsTrId("sailfish_browser-la-cert_content_display_loaded")
                    } else if (security.blockedMixedActiveContent) {
                        //% "Parts of the page that are not secure have been blocked"
                        return qsTrId("sailfish_browser-la-cert_content_active_blocked")
                    } else if (security.blockedMixedDisplayContent) {
                        //% "Parts of the page that are not secure have been blocked"
                        return qsTrId("sailfish_browser-la-cert_content_display_blocked")
                    }
                }
                return ""
            }
            tabPos: 0
            danger: true
        }

        CertificateLabel {
            //: Label for the owner field of a TLS certificate
            //% "Owner"
            key: qsTrId("sailfish_browser-la-cert_owner")
            value: security ? security.subjectOrganization : ""
            happy: security && security.allGood
        }

        CertificateLabel {
            //: Label for the subject field of a TLS certificate
            //% "Website"
            key: qsTrId("sailfish_browser-la-cert_subject")
            value: security ? security.subjectDisplayName : ""
        }

        CertificateLabel {
            //: Label for the issuer field of a TLS certificate
            //% "Issuer"
            key: qsTrId("sailfish_browser-la-cert_issuer")
            value: security ? security.issuerDisplayName : ""
        }

        CertificateLabel {
            //: Label for the effective/start date field of a TLS certificate
            //% "Starts"
            key: qsTrId("sailfish_browser-la-cert_starts")
            value: danger ? Format.formatDate(security.effectiveDate, Formatter.DateMedium) : ""
            danger: security && security.notValidAtThisTime
        }

        CertificateLabel {
            //: Label for the expiration/end date field of a TLS certificate
            //% "Ends"
            key: qsTrId("sailfish_browser-la-cert_ends")
            value : danger ? Format.formatDate(security.expiryDate, Formatter.DateMedium) : ""
            danger: security && security.notValidAtThisTime
        }

        CertificateLabel {
            //: Label prefixing the status of whether tracking tech is being used on a page
            //% "Tracking"
            key: qsTrId("sailfish_browser-la-cert_tracking")
            value: {
                if (security) {
                    if (security.loadedTrackingContent) {
                        //% "The page includes items used to track your behaviour"
                        return qsTrId("sailfish_browser-la-cert_tracking_content_loaded")
                    } else if (security.blockedTrackingContent) {
                        //% "Items used to track your behaviour have been blocked"
                        return qsTrId("sailfish_browser-la-cert_tracking_content_blocked")
                    }
                }
                return ""
            }
            danger: security && security.loadedTrackingContent
        }
    }

    Item {
        id: showMoreSpacing
        width: parent.width
        visible: security && !security.certIsNull
        height: visible ? buttonHeight : 0
        anchors.bottom: parent.bottom

        BackgroundItem {
            id: showMore
            height: Theme.itemSizeExtraSmall
            anchors.verticalCenter: parent.verticalCenter

            onClicked: {
                console.log("Security: more")
                showCertDetail()
            }

            Private.ShowMoreButton {
                x: Theme.horizontalPageMargin
                y: showMore.height/2 - height/2
                highlighted: showMore.highlighted
                enabled: false
            }
        }
    }
}
