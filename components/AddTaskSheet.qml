/***************************************************************************
 * Whatsoever ye do in word or deed, do all in the name of the             *
 * Lord Jesus, giving thanks to God and the Father by him.                 *
 * - Colossians 3:17                                                       *
 *                                                                         *
 * SuperTask Pro - A task management system for Ubuntu Touch               *
 * Copyright (C) 2013 Michael Spencer <spencers1993@gmail.com>             *
 *                                                                         *
 * This program is free software: you can redistribute it and/or modify    *
 * it under the terms of the GNU General Public License as published by    *
 * the Free Software Foundation, either version 3 of the License, or       *
 * (at your option) any later version.                                     *
 *                                                                         *
 * This program is distributed in the hope that it will be useful,         *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of          *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the            *
 * GNU General Public License for more details.                            *
 *                                                                         *
 * You should have received a copy of the GNU General Public License       *
 * along with this program. If not, see <http://www.gnu.org/licenses/>.    *
 ***************************************************************************/
import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Popups 0.1

ComposerSheet {
    id: root

    title: i18n.tr("Add Task")

    Flickable {
        anchors.fill: parent
        contentHeight: contents.height
        contentWidth: contents.width

        clip: true

        Column {
            id: contents
            width: root.width - units.gu(2)


            Empty {
                TextField {
                    anchors.fill: parent
                    anchors.margins: units.gu(1)

                    placeholderText: "Title"
                    font.bold: true
                }
            }

            Empty {
                height: textField.height + units.gu(2)
                anchors.bottomMargin: units.gu(1)

                TextArea {
                    id: textField
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: units.gu(1)
                    }

                    autoSize: true
                    placeholderText: "Contents"
                }
            }

            Empty {
                TextField {
                    anchors.fill: parent
                    anchors.margins: units.gu(1)

                    placeholderText: "Due Date"
                }
            }

            ValueSelector {
                text: i18n.tr("Importance")
                values: ["Low", "Medium", "High"]
            }
        }
    }
}
