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

Item {
    id: root

    property string title

    property var tasks: taskListModel


    ListModel {
        id: taskListModel
    }

    function loadJSON(json) {
        title = json.title

        if (json.hasOwnProperty("tasks")) {
            for (var i = 0; i < json.tasks.length; i++) {
                addTask(json.tasks[i])
            }
        }
    }

    function toJSON() {
        var json = {}

        json.title = title
        json.tasks = []

        for (var i = 0; i < taskListModel.count; i++) {
            json.tasks.push(taskListModel.get(i).modelData)
        }

        return json
    }

    function length() {
        if (tasks.hasOwnProperty("count")) {
            return tasks.count
        } else {
            return tasks.length
        }
    }

    function addTask(args) {
        var task = taskComponent.createObject(root, args)

        if (task === null) {
            console.log("Unable to create task!")
        }

        taskListModel.append({"modelData": task})
    }

    function newTask() {
        return taskComponent.createObject(root)
    }

    function removeTask(task) {
        for (var i = 0; i < taskListModel.count; i++) {
            if (taskListModel.get(i).modelData === task) {
                taskListModel.remove(i)
                return
            }
        }
    }

    function remove() {
        removeTaskList(root)
    }

    Component {
        id: taskComponent

        Task {

        }
    }
}
