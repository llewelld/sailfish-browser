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
import Sailfish.Browser 1.0
import Qt5Mozilla 1.0
import "." as Browser

Item {
    property QMozSecurity security
    readonly property bool _validCert: security && security.subjectDisplayName.length > 0
    visible: security
    property real animatePos

    function animateOffset(animatePos, offset) {
        var total = 11.0
        var shift = offset * (1.0 / total)
        var anim = Math.max(animatePos - shift, 0.0) / (1.0 - shift)
        return anim
    }

    Column {
        spacing: Theme.paddingSmall
        width: parent.width

        CertLabel {
            //: Label for the owner field of a TLS certificate
            //% "Owner"
            key: qsTrId("sailfish_browser-la-cert_owner")
            value: security ? security.subjectOrganization : ""
            happy: security && security.allGood
            opacity: animateOffset(animatePos, 0)
        }

        CertLabel {
            //: Label for the subject field of a TLS certificate
            //% "Subject"
            key: qsTrId("sailfish_browser-la-cert_subject")
            value: security ? security.subjectDisplayName : ""
            opacity: animateOffset(animatePos, 1)
        }

        CertLabel {
            //: Label for the issuer field of a TLS certificate
            //% "Issuer"
            key: qsTrId("sailfish_browser-la-cert_issuer")
            value: security ? security.issuerDisplayName : ""
            opacity: animateOffset(animatePos, 2)
        }

        CertLabel {
            //: Label for the effective/start date field of a TLS certificate
            //% "Starts"
            key: qsTrId("sailfish_browser-la-cert_starts")
            value: security ? Format.formatDate(security.effectiveDate, Formatter.DateMedium) : ""
            danger: security && security.notValidAtThisTime
            opacity: animateOffset(animatePos, 3)
        }

        CertLabel {
            //: Label for the expiration/end date field of a TLS certificate
            //% "Ends"
            key: qsTrId("sailfish_browser-la-cert_ends")
            value : security ? Format.formatDate(security.expiryDate, Formatter.DateMedium) : ""
            danger: security && security.notValidAtThisTime
            opacity: animateOffset(animatePos, 4)
        }

        CertLabel {
            //: Label prefixing the status of whether tracking tech is being used on a page
            //% "Tracking"
            key: qsTrId("sailfish_browser-la-cert_tracking")
            value: {
                if (security) {
                    if (security.loadedTrackingContent) {
                        //% "Tracking content loaded"
                        return qsTrId("sailfish_browser-la-cert_tracking_content_loaded")
                    } else if (security.blockedTrackingContent) {
                        //% "Tracking content blocked"
                        return qsTrId("sailfish_browser-la-cert_tracking_content_blocked")
                    }
                }
                return ""
            }
            danger: security && security.loadedTrackingContent
            opacity: animateOffset(animatePos, 5)
        }

        CertLabel {
            //: Label prefixing the status of whether dangerous content has been blocked or loaded
            //% "Content"
            key: qsTrId("sailfish_browser-la-cert_content")
            value: {
                if (security) {
                    if (security.blockedMixedActiveContent) {
                        //% "Active mixed content blocked"
                        return qsTrId("sailfish_browser-la-cert_content_active_blocked")
                    } else if (security.loadedMixedActiveContent) {
                        //% "Active mixed content loaded"
                        return qsTrId("sailfish_browser-la-cert_content_active_loaded")
                    } else if (security.blockedMixedDisplayContent) {
                        //% "Display mixed content blocked"
                        return qsTrId("sailfish_browser-la-cert_content_display_blocked")
                    } else if (security.loadedMixedDisplayContent) {
                        //% "Display mixed content loaded"
                        return qsTrId("sailfish_browser-la-cert_content_display_loaded")
                    }
                }
                return ""
            }
            danger: security && (security.loadedMixedActiveContent || security.loadedMixedDisplayContent)
            opacity: animateOffset(animatePos, 6)
        }

        CertLabel {
            //: Label prefixing the overal TLS security state of a page
            //% "Status"
            key: qsTrId("sailfish_browser-la-cert_status")
            value: {
                if (security) {
                    if (security.untrusted) {
                        //: Certificate trust chain is broken, for example
                        //% "Untrusted"
                        return qsTrId("sailfish_browser-la-cert_status_untrusted")
                    } else if (security.isInsecure) {
                        //: Connection is known to be insecure
                        //% "Insecure"
                        return qsTrId("sailfish_browser-la-cert_status_insecure")
                    } else if (security.isBroken) {
                        //: Connection security is broken, for example has mixed secure and insecure content
                        //% "Broken"
                        return qsTrId("sailfish_browser-la-cert_status_broken")
                    } else if (!security.isSecure) {
                        //: There is no security applied to the connection
                        //% "Not secure"
                        return qsTrId("sailfish_browser-la-cert_status_not_secure")
                    } else if (!security.allGood) {
                        return qsTrId("sailfish_browser-la-cert_status_not_secure")
                    }
                    //: Connection is secure (confidentiality and integrity
                    //% "Secure"
                    return qsTrId("sailfish_browser-la-cert_status_secure")
                }
                //: No security applied or security status of connection unknown
                //% "No security"
                return qsTrId("sailfish_browser-la-cert_status_no_security")
            }
            danger: !security || !security.allGood
            happy: security && security.allGood
            opacity: animateOffset(animatePos, 7)
        }

        CertLabel {
            //: The domain in the TLS certificate and the domain connected to are not the same
            //% "Certificate is for a different domain"
            value: qsTrId("sailfish_browser-la-cert_domain_mismatch")
            tabPos: 0
            visible: _validCert && security.domainMismatch
            danger: true
            opacity: animateOffset(animatePos, 8)
        }

        CertLabel {
            //: The TLS certificate has expired or is not yet valid
            //% "Certificate has expired or is not yet valid"
            value: qsTrId("sailfish_browser-la-cert_not_valid_at_this_time")
            tabPos: 0
            visible: _validCert && security.notValidAtThisTime
            danger: true
            opacity: animateOffset(animatePos, 9)
        }

        CertLabel {
            //: The TLS certificate is insecure because it uses weak encryption or hashing methods
            //% "Certificate uses weak crypto"
            value: qsTrId("sailfish_browser-la-cert_weak_crypto")
            tabPos: 0
            visible: _validCert && (security.usesWeakCrypto)
            danger: true
            opacity: animateOffset(animatePos, 10)
        }
    }
}
