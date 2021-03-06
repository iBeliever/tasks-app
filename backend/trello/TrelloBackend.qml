/***************************************************************************
 * Whatsoever ye do in word or deed, do all in the name of the             *
 * Lord Jesus, giving thanks to God and the Father by him.                 *
 * - Colossians 3:17                                                       *
 *                                                                         *
 * Ubuntu Tasks - A task management system for Ubuntu Touch                *
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
import Ubuntu.Components.Popups 0.1
import U1db 1.0 as U1db
import ".."
import "../local" as Local

GenericBackend {
    id: root

    name: "Trello Boards"
    newName: "Trello Board"
    requiresInternet: true
    databaseName: "trello"
    enabled: token !== "" && trelloIntegration
    //editable: false
    supportsStatistics: false
    property bool firstLoad: false
    supportsMultipleUsers: true

    customReloadFields: function() {
        userName = database.get("userName", "me")
    }

    customSaveFields: function() {
        database.set("userName", userName)
    }

    function newProject(name) {
        var project = createProject({
                          docId: nextDocId++
                      })
        project.name = name
        internal_addProject(project)
        project.loadU1db()
        project.locked = true
        httpPOST("/boards", ["name=" + name], onNewProject, project)
        return project
    }

    function onNewProject(response, project) {
        var json = JSON.parse(response)
        project.boardID = json.id
        httpGET("/boards/" + project.boardID + "/lists", [], project.loadLists)
        project.locked = false
    }

    function getBoard(boardID) {
        for (var i = 0; i < projects.count; i++) {
            if (projects.get(i).modelData.boardID === boardID)
                return projects.get(i).modelData
        }
    }

    function load(json) {
        token = getSetting("trelloToken", "")
        print("Trello token:", token, trelloIntegration)

        print(">>>>>LOADING>>>>>>>>>>>>>>>")

        database.load(json)

        if (token != "") {
            loadU1db(json)
            authorized()
        }

        loaded = true
    }

    property bool loaded: false

    function connect() {
        firstLoad = true
        authorized()
    }

    function internal_newProject() {
        print("Creating new project...")
        var project = createProject({
                          docId: nextDocId++
                      })
        internal_addProject(project)
        project.loadU1db()
        return project
    }

    function onUserLoaded(response) {
        var json = JSON.parse(response)

        print("USER AVATAR>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        print(JSON.stringify(json))
        userName = json.id
        print(userName)
    }

    function onLoaded(response) {
        var json = JSON.parse(response)
        print("Boards loaded:", json)
        var boards = json
        for (var i = 0; i < boards.length; i++) {
            var board = getBoard(boards[i].id)
            if (board === undefined) {
                board = internal_newProject()
                board.loadTrello(boards[i])
                board.refresh()
            } else {
                board.loadTrello(boards[i])
            }
        }
        for (var k = 0; k < projects.count; k++) {
            var project = projects.get(k).modelData
            var found = false
            if (project.locked) continue;

            for (var j = 0; j < json.length; j++) {
                if (project.boardID === json[j].id) {
                    found = true
                    break
                }
            }

            if (!found)
                internal_removeProject(project)
        }
    }

    function authorized() {
        httpGET("/members/my/boards", ["filter=pinned"], onLoaded)
        httpGET("/members/me", [], onUserLoaded)
    }

    function refresh() {
        authorized()
        for (var i = 0; i < length(projects); i++) {
            var board = getItem(projects, i)
            if (board !== undefined)
                board.refresh()
        }
    }

    // For loading a project from U1db
    function loadProjectU1db(docId) {
        var project = createProject({
                                        docId: docId
                                    })
        internal_addProject(project)
        project.loadU1db()
        project.refresh()
        return project
    }

    projectComponent: Component {

        Project {

        }
    }

    /* INTERNAL FUNCTIONS */

    readonly property string key: "333870c6f8dc97cb6a14e79dfe119675"
    readonly property string secret: "1be63ceca6fcf130bfb61e68c9d85fcd9d1adeda3671fcee61d86d2bc236e7c3"
    property string token
    property string responseText

    function call(path, options, callback) {
        httpGET(path, options, callback)
    }

    function httpPOST(path, options, callback, args) {
        request(path, "POST", options, callback, args)
    }

    function httpPUT(path, options, callback, args) {
        request(path, "PUT", options, callback, args)
    }

    function httpDELETE(path, options, callback, args) {
        request(path, "DELETE", options, callback, args)
    }

    function httpGET(path, options, callback, args) {
        request(path, "GET", options, callback, args)
    }

    function request(path, call, options, callback, args) {
        var address = "https://trello.com/1" + path + "?key=" + key + "&token=" + token
        //print(token)

        if (options === undefined)
            options = []

        if (token === "")
            Qt.quit()
        if (options.length > 0)
            address += "&" + options.join("&").replace(" ", "+")

        if (call === "PUT")
            print(call, address)

        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (call !== "GET" || firstLoad) {
                    loading--
                    if (loading === 0)
                        totalLoading = 0
                }
                //print(call, path, options.join("&").replace(" ", "+"))
                //print("Response:", doc.responseText)
                if (callback !== undefined)
                    callback(doc.responseText, args)
            }
         }

        doc.open(call, address);
        //doc.setRequestHeader("Accept", "application/json")
        doc.send();

        if (call !== "GET" | firstLoad) {
            loading++
            totalLoading++
        }
    }

    function authenticate(name) {
        Qt.openUrlExternally("https://trello.com/1/authorize?" + "key=" +
                             key + "&name=" + name.replace(" ", "+") +
                             "&expiration=30days&response_type=token&scope=read,write")
    }
}
