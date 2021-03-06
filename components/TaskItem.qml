/***************************************************************************
 * Whatsoever ye do in word or deed, do all in the name of the             *
 * Lord Jesus, giving thanks to God and the Father by him.                 *
 * - Colossians 3:17                                                       *
 *                                                                         *
 * Ubuntu Tasks - A task management system for Ubuntu Touch                *
 * Copyright (C) 2013 Michael Spencer <sonrisesoftware@gmail.com>          *
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
import "../components"
import "../ubuntu-ui-extras"

Item {
    id: taskItem

    property var task

    property bool creating: false

    property var flickable: flickable

    Flickable {
        id: flickable
        contentHeight: column.height
        contentWidth: width

        clip: true

        anchors {
            top: parent.top
            left: sidebar.mode === "left" ? sidebar.right : parent.left
            right: sidebar.mode === "left" ? parent.right : sidebar.left
            bottom: parent.bottom
        }

        Column {
            id: column

            width: flickable.width

            Item {
                height: headerItem.height + descriptionTextArea.height + units.gu(6)

                width: parent.width

                Item {
                    id: headerItem
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: units.gu(2)
                    }

                    height: completedCheckBox.visible
                            ? Math.max(titleLabel.height, completedCheckBox.height)
                            : titleLabel.height

                    EditableLabel {
                        id: titleLabel

                        anchors.verticalCenter: parent.verticalCenter
                        anchors {
                            left: completedCheckBox.visible ? completedCheckBox.right : parent.left
                            leftMargin: completedCheckBox.visible ? units.gu(2) : 0
                            right: parent.right
                        }

                        inlineEdit: false
                        showEditIcon: false
                        fontSize: "large"
                        bold: true
                        text: task.name
                        editable: task.canEdit("name")
                        placeholderText: i18n.tr("Title")
                        parentEditing: creating

                        onDoneEditing: {
                            task.name = text
                            text = Qt.binding(function() { return task.name })
                        }
                    }

                    CheckBox {
                        id: completedCheckBox
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                        }

                        visible: !creating && !titleLabel.editing && task.canEdit("completed")
                        __acceptEvents: task.canComplete && task.editable


                        checked: task.completed
                        onCheckedChanged: {
                            task.completed = checked
                            checked = Qt.binding(function() {return task.completed})
                        }
                        style: SuruCheckBoxStyle {}
                    }

                    Label {
                        anchors.centerIn: completedCheckBox
                        text: task.checklist.percent + "%"
                        visible: !task.completed && task.hasChecklist && completedCheckBox.visible
                    }

//                    UbuntuShape {
//                        id: priorityShape
//                        anchors {
//                            left: parent.left
//                            verticalCenter: headerItem.verticalCenter
//                        }
//                        visible: !creating && !titleLabel.editing// && task.priority !== "low"
//                        width: units.gu(3)
//                        height: width
//                        color: priorityColor(task.priority)
//                    }
                }

                TextArea {
                    id: descriptionTextArea
                    anchors {
                        top: headerItem.bottom
                        left: parent.left
                        right: parent.right
                        margins: units.gu(2)
                    }

                    Component.onCompleted: __styleInstance.color = "white"

                    readOnly: !task.canEdit("description")
                    text: task.description
                    placeholderText: i18n.tr("Description")

                    onFocusChanged: {
                        __styleInstance.color = (focus ? Theme.palette.normal.overlayText : "white")

                        if (focus) {
                            text = Qt.binding(function() { return task.description})
                        } else {
                            task.description = text
                        }
                    }
                }
            }

            ThinDivider {
                id: textDivider
                visible: task.hasChecklist
            }

            Item {
                id: checklistItem
                scale: visible ? 1 : 0
                height: checklist.visible ? checklist.height + checklist.y : 0
                width: parent.width
                clip: true

                Behavior on height {
                    UbuntuNumberAnimation {}
                }

                Checklist {
                    id: checklist
                    visible: task.hasChecklist
                    task: taskItem.task
                    width: parent.width
                }
            }

            TaskItemOptions {
                visible: !sidebar.expanded
                width: parent.width
                task: taskItem.task
            }
        }
    }

    Scrollbar {
        flickableItem: flickable
    }

    Sidebar {
        id: sidebar
        mode: "right"
        expanded: wideAspect

        TaskItemOptions {
            id: options
            width: parent.width

            task: taskItem.task
        }
    }
}
