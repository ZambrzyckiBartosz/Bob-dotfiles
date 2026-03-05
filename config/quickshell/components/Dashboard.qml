import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

PanelWindow {
    id: dashboard
    visible: true
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; right: true }
    margins { top: 40; bottom: 10; right: root.dashboardVisible ? 6 : -450 }
    implicitWidth: 420
    color: "transparent"
    focusable: true
    WlrLayershell.keyboardFocus: root.dashboardVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    Behavior on margins.right { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

    property int cpuVal: 0
    property int tempVal: 0
    property int ramVal: 0
    property int diskVal: 0
    property int batVal: 100
    property int volVal: 50
    property int brightVal: 100
    property int updateVal: 0
    property string netDown: "0 KB/s"
    property string netUp: "0 KB/s"
    property string configPath: Quickshell.env("HOME") + "/.config/quickshell"

    property var monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    property var daysOfWeek: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    property int currentMonth: new Date().getMonth()
    property int currentYear: new Date().getFullYear()
    property int currentDay: new Date().getDate()
    property int viewMonth: currentMonth
    property int viewYear: currentYear
    property var calendarModel: []

    function updateCalendar() {
        var firstDay = new Date(viewYear, viewMonth, 1).getDay()
        var startPad = (firstDay === 0) ? 6 : firstDay - 1
        var daysInMonth = new Date(viewYear, viewMonth + 1, 0).getDate()
        var arr = []
        for (var i = 0; i < startPad; i++) arr.push("")
        for (var i = 1; i <= daysInMonth; i++) arr.push(i.toString())
        while (arr.length % 7 !== 0) arr.push("")
        calendarModel = arr
    }

    Component.onCompleted: {
        updateCalendar()
    }

    Item {
        anchors.fill: parent
        focus: root.dashboardVisible

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                if (profileSection.pfpPickerOpen) {
                    profileSection.pfpPickerOpen = false
                } else {
                    root.dashboardVisible = false
                }
                event.accepted = true
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(root.walBackground.r, root.walBackground.g, root.walBackground.b, 0.7)
            radius: 20

            MouseArea {
                anchors.fill: parent
                visible: profileSection.pfpPickerOpen
                onClicked: profileSection.pfpPickerOpen = false
                z: 50
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                z: 100

                Rectangle {
                    id: profileSection
                    Layout.fillWidth: true
                    Layout.preferredHeight: pfpPickerOpen ? 280 : 100
                    color: Qt.rgba(0, 0, 0, 0.3)
                    radius: 15
                    clip: true
                    property bool pfpPickerOpen: false
                    Behavior on Layout.preferredHeight { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 15
                            Item {
                                id: pfpContainer
                                width: 74
                                height: 74
                                Rectangle {
                                    id: pfpBorder
                                    anchors.fill: parent
                                    radius: 37
                                    color: "transparent"
                                    border.width: 3
                                    border.color: root.walColor5
                                }
                                Image {
                                    id: pfpImage
                                    anchors.centerIn: parent
                                    width: 68
                                    height: 68
                                    source: "file://" + dashboard.configPath + "/assets/pfps/pfp.jpg"
                                    fillMode: Image.PreserveAspectCrop
                                    smooth: true
                                    cache: false
                                    sourceSize.width: 256
                                    sourceSize.height: 256
                                    visible: false
                                    property int reloadTrigger: 0
                                    function reload() {
                                        reloadTrigger++
                                        source = ""
                                        source = "file://" + dashboard.configPath + "/assets/pfps/pfp.jpg?" + reloadTrigger
                                    }
                                }
                                Rectangle {
                                    id: pfpMask
                                    anchors.centerIn: parent
                                    width: 68
                                    height: 68
                                    radius: 34
                                    visible: false
                                }
                                OpacityMask {
                                    anchors.centerIn: parent
                                    width: 68
                                    height: 68
                                    source: pfpImage
                                    maskSource: pfpMask
                                }
                                Rectangle {
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    width: 22
                                    height: 22
                                    radius: 11
                                    color: root.walColor5
                                    border.width: 2
                                    border.color: root.walBackground
                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰏫"
                                        color: root.walBackground
                                        font.pixelSize: 12
                                        font.family: "JetBrainsMono Nerd Font"
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        profileSection.pfpPickerOpen = !profileSection.pfpPickerOpen
                                        if (profileSection.pfpPickerOpen) {
                                            root.pfpFiles = []
                                            pfpListProc.running = true
                                        }
                                    }
                                }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 5
                                Text {
                                    text: Quickshell.env("USER")
                                    color: root.walColor5
                                    font.pixelSize: 26
                                    font.bold: true
                                    font.family: "JetBrainsMono Nerd Font"
                                }
                                Text {
                                    id: uptimeText
                                    text: "up ..."
                                    color: root.walForeground
                                    font.pixelSize: 12
                                    font.family: "JetBrainsMono Nerd Font"
                                }
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: Qt.rgba(0, 0, 0, 0.3)
                            radius: 10
                            visible: profileSection.pfpPickerOpen
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8
                                Text {
                                    text: "Choose Avatar"
                                    color: root.walColor5
                                    font.pixelSize: 12
                                    font.bold: true
                                    font.family: "JetBrainsMono Nerd Font"
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                Flickable {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    contentWidth: width
                                    contentHeight: pfpGrid.height
                                    clip: true
                                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                                    GridLayout {
                                        id: pfpGrid
                                        width: parent.width
                                        columns: 6
                                        rowSpacing: 8
                                        columnSpacing: 8
                                        Repeater {
                                            model: root.pfpFiles
                                            Item {
                                                width: 48
                                                height: 48
                                                Layout.alignment: Qt.AlignHCenter
                                                Rectangle {
                                                    anchors.fill: parent
                                                    radius: 24
                                                    color: "transparent"
                                                    border.width: 2
                                                    border.color: thumbMa.containsMouse ? root.walColor13 : root.walColor5
                                                    Behavior on border.color { ColorAnimation { duration: 150 } }
                                                }
                                                Image {
                                                    id: thumbImg
                                                    anchors.centerIn: parent
                                                    width: 44
                                                    height: 44
                                                    source: "file://" + modelData
                                                    fillMode: Image.PreserveAspectCrop
                                                    smooth: true
                                                    sourceSize.width: 128
                                                    sourceSize.height: 128
                                                    visible: false
                                                }
                                                Rectangle {
                                                    id: thumbMask
                                                    anchors.centerIn: parent
                                                    width: 44
                                                    height: 44
                                                    radius: 22
                                                    visible: false
                                                }
                                                OpacityMask {
                                                    anchors.centerIn: parent
                                                    width: 44
                                                    height: 44
                                                    source: thumbImg
                                                    maskSource: thumbMask
                                                }
                                                MouseArea {
                                                    id: thumbMa
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        setPfpProc.selFile = modelData
                                                        setPfpProc.running = true
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Process {
                        id: pfpListProc
                        command: ["bash", "-c", "find " + dashboard.configPath + "/assets/pfps -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.png' -o -iname '*.gif' \\) ! -name 'pfp.jpg' | sort"]
                        stdout: SplitParser {
                            onRead: data => {
                                var file = data.trim()
                                if (file.length > 0) {
                                    var current = root.pfpFiles.slice()
                                    current.push(file)
                                    root.pfpFiles = current
                                }
                            }
                        }
                    }
                    Process {
                        id: setPfpProc
                        property string selFile: ""
                        command: ["bash", "-c", "cp '" + selFile + "' " + dashboard.configPath + "/assets/pfps/pfp.jpg"]
                        onExited: {
                            pfpImage.reload()
                            profileSection.pfpPickerOpen = false
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: Qt.rgba(0, 0, 0, 0.3)
                    radius: 15
                    Row {
                        anchors.centerIn: parent
                        spacing: 12 
                        
                        PowerBtn { icon: "󰚰"; iconColor: dashboard.updateVal > 0 ? "#fab387" : root.walColor8; cmd: "kitty -e yay -Syu" }
                        PowerBtn { icon: "󰃢"; iconColor: root.walColor4; cmd: "kitty -e bash -c 'cat ~/.cache/wal/sequences; /home/bob/.config/scripts/sysclean'" }
                        PowerBtn { icon: "⏻"; iconColor: root.walColor2; cmd: "systemctl poweroff" }
                        PowerBtn { icon: "󰜉"; iconColor: root.walColor13; cmd: "systemctl reboot" }
                        PowerBtn { icon: "󰌾"; iconColor: root.walColor5; cmd: "hyprlock" }
                        PowerBtn { icon: "󰒲"; iconColor: root.walColor4; cmd: "systemctl suspend" }
                        PowerBtn { icon: "󰍃"; iconColor: root.walColor1; cmd: "hyprctl dispatch exit" }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    color: Qt.rgba(0, 0, 0, 0.3)
                    radius: 15
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15
                        Text {
                            id: batIcon
                            text: "󰁹"
                            color: root.walColor2
                            font.pixelSize: 32
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3
                            Text {
                                text: "Battery " + dashboard.batVal + "%"
                                color: root.walForeground
                                font.pixelSize: 18
                                font.family: "JetBrainsMono Nerd Font"
                            }
                            Text {
                                id: batStatus
                                text: "Checking..."
                                color: root.walColor8
                                font.pixelSize: 12
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 140
                    color: Qt.rgba(0, 0, 0, 0.3)
                    radius: 15
                    Row {
                        anchors.centerIn: parent
                        spacing: 15 
                        CircularStat { label: "CPU"; icon: ""; barColor: root.walColor1; value: dashboard.cpuVal; suffix: "%" }
                        CircularStat { label: "TEMP"; icon: ""; barColor: root.walColor2; value: dashboard.tempVal; suffix: "°C" }
                        CircularStat { label: "RAM"; icon: ""; barColor: root.walColor5; value: dashboard.ramVal; suffix: "%" }
                        CircularStat { label: "DISK"; icon: ""; barColor: root.walColor4; value: dashboard.diskVal; suffix: "%" }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    color: Qt.rgba(0, 0, 0, 0.3)
                    radius: 15
                    Column {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15
                        Row {
                            width: parent.width
                            spacing: 10
                            Text {
                                width: 25
                                text: dashboard.volVal == 0 ? "󰝟" : dashboard.volVal < 50 ? "󰖀" : "󰕾"
                                color: root.walColor4
                                font.pixelSize: 18
                                font.family: "JetBrainsMono Nerd Font"
                                verticalAlignment: Text.AlignVCenter
                                height: 24
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: volMuteProc.running = true
                                }
                                Process {
                                    id: volMuteProc
                                    command: ["bash", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"]
                                    onExited: volProc.running = true
                                }
                            }
                            Rectangle {
                                id: volSlider
                                width: parent.width - 75
                                height: 8
                                anchors.verticalCenter: parent.verticalCenter
                                radius: 4
                                color: Qt.rgba(0,0,0,0.3)
                                Rectangle {
                                    width: parent.width * dashboard.volVal / 100
                                    height: parent.height
                                    radius: 4
                                    color: root.walColor4
                                    Behavior on width { NumberAnimation { duration: 100 } }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: function(mouse) {
                                        var percent = Math.round((mouse.x / parent.width) * 100)
                                        percent = Math.max(0, Math.min(100, percent))
                                        dashboard.volVal = percent
                                        volSetProc.command = ["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + (percent / 100).toFixed(2)]
                                        volSetProc.running = true
                                    }
                                    onPositionChanged: function(mouse) {
                                        if (pressed) {
                                            var percent = Math.round((mouse.x / parent.width) * 100)
                                            percent = Math.max(0, Math.min(100, percent))
                                            dashboard.volVal = percent
                                            volSetProc.command = ["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + (percent / 100).toFixed(2)]
                                            volSetProc.running = true
                                        }
                                    }
                                }
                                Process { id: volSetProc }
                            }
                            Text {
                                width: 40
                                text: dashboard.volVal + "%"
                                color: root.walColor8
                                font.pixelSize: 11
                                font.family: "JetBrainsMono Nerd Font"
                                horizontalAlignment: Text.AlignRight
                                verticalAlignment: Text.AlignVCenter
                                height: 24
                            }
                        }
                        Row {
                            width: parent.width
                            spacing: 10
                            Text {
                                width: 25
                                text: dashboard.brightVal < 30 ? "󰃞" : dashboard.brightVal < 70 ? "󰃟" : "󰃠"
                                color: root.walColor13
                                font.pixelSize: 18
                                font.family: "JetBrainsMono Nerd Font"
                                verticalAlignment: Text.AlignVCenter
                                height: 24
                            }
                            Rectangle {
                                id: brightSlider
                                width: parent.width - 75
                                height: 8
                                anchors.verticalCenter: parent.verticalCenter
                                radius: 4
                                color: Qt.rgba(0,0,0,0.3)
                                Rectangle {
                                    width: parent.width * dashboard.brightVal / 100
                                    height: parent.height
                                    radius: 4
                                    color: root.walColor13
                                    Behavior on width { NumberAnimation { duration: 100 } }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: function(mouse) {
                                        var percent = Math.round((mouse.x / parent.width) * 100)
                                        percent = Math.max(1, Math.min(100, percent))
                                        dashboard.brightVal = percent
                                        brightSetProc.command = ["bash", "-c", "brightnessctl set " + percent + "%"]
                                        brightSetProc.running = true
                                    }
                                    onPositionChanged: function(mouse) {
                                        if (pressed) {
                                            var percent = Math.round((mouse.x / parent.width) * 100)
                                            percent = Math.max(1, Math.min(100, percent))
                                            dashboard.brightVal = percent
                                            brightSetProc.command = ["bash", "-c", "brightnessctl set " + percent + "%"]
                                            brightSetProc.running = true
                                        }
                                    }
                                }
                                Process { id: brightSetProc }
                            }
                            Text {
                                width: 40
                                text: dashboard.brightVal + "%"
                                color: root.walColor8
                                font.pixelSize: 11
                                font.family: "JetBrainsMono Nerd Font"
                                horizontalAlignment: Text.AlignRight
                                verticalAlignment: Text.AlignVCenter
                                height: 24
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 115
                    color: Qt.rgba(0, 0, 0, 0.3)
                    radius: 15
                    Column {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 8
                        Text {
                            id: timeDisplay
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "12:00:00 AM"
                            color: root.walColor5
                            font.pixelSize: 40
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 20
                            Text {
                                text: "󰇚 " + dashboard.netDown
                                color: root.walColor4
                                font.pixelSize: 16
                                font.family: "JetBrainsMono Nerd Font"
                            }
                            Text {
                                text: "󰕒 " + dashboard.netUp
                                color: root.walColor2
                                font.pixelSize: 16
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 250
                    color: Qt.rgba(0, 0, 0, 0.3)
                    radius: 15

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 12

                        RowLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: ""
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 16
                                color: maLeft.containsMouse ? root.walColor13 : root.walColor8
                                MouseArea {
                                    id: maLeft
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (dashboard.viewMonth === 0) {
                                            dashboard.viewMonth = 11;
                                            dashboard.viewYear--;
                                        } else {
                                            dashboard.viewMonth--;
                                        }
                                        dashboard.updateCalendar();
                                    }
                                }
                            }

                            Text {
                                text: dashboard.monthNames[dashboard.viewMonth] + " " + dashboard.viewYear
                                color: root.walColor5
                                font.pixelSize: 16
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Text {
                                text: ""
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 16
                                color: maRight.containsMouse ? root.walColor13 : root.walColor8
                                MouseArea {
                                    id: maRight
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (dashboard.viewMonth === 11) {
                                            dashboard.viewMonth = 0;
                                            dashboard.viewYear++;
                                        } else {
                                            dashboard.viewMonth++;
                                        }
                                        dashboard.updateCalendar();
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Repeater {
                                model: dashboard.daysOfWeek
                                Text {
                                    text: modelData
                                    color: root.walColor8
                                    font.pixelSize: 12
                                    font.family: "JetBrainsMono Nerd Font"
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }

                        GridLayout {
                            columns: 7
                            rowSpacing: 5
                            columnSpacing: 5
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Repeater {
                                model: dashboard.calendarModel
                                Rectangle {
                                    property bool isToday: (modelData !== "" && parseInt(modelData) === dashboard.currentDay && dashboard.viewMonth === dashboard.currentMonth && dashboard.viewYear === dashboard.currentYear)
                                    
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    color: isToday ? root.walColor5 : "transparent"
                                    radius: 8

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData
                                        color: parent.isToday ? root.walBackground : root.walForeground
                                        font.pixelSize: 14
                                        font.bold: parent.isToday
                                        font.family: "JetBrainsMono Nerd Font"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: root
        function onDashboardVisibleChanged() {
            if (root.dashboardVisible) {
                focusTimer.start()
            }
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: {
            dashboard.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
            releaseTimer.start()
        }
    }

    Timer {
        id: releaseTimer
        interval: 100
        repeat: false
        onTriggered: {
            dashboard.WlrLayershell.keyboardFocus = WlrKeyboardFocus.OnDemand
        }
    }

    component CircularStat: Item {
        property string label
        property string icon
        property color barColor
        property int value
        property string suffix: "%"
        width: 80
        height: 110
        Column {
            anchors.centerIn: parent
            spacing: 8
            Item {
                width: 70
                height: 70
                anchors.horizontalCenter: parent.horizontalCenter
                Canvas {
                    anchors.fill: parent
                    property int statValue: value
                    onStatValueChanged: requestPaint()
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        ctx.lineWidth = 5
                        ctx.lineCap = "round"
                        ctx.strokeStyle = Qt.rgba(0, 0, 0, 0.3)
                        ctx.beginPath()
                        ctx.arc(35, 35, 32, 0, 2 * Math.PI)
                        ctx.stroke()
                        ctx.strokeStyle = barColor
                        ctx.beginPath()
                        
                        var mathPercent = statValue
                        if (suffix === "°C") {
                            mathPercent = (statValue / 100) * 100
                        }
                        
                        ctx.arc(35, 35, 32, -Math.PI / 2, -Math.PI / 2 + (mathPercent / 100) * 2 * Math.PI)
                        ctx.stroke()
                    }
                }
                Column {
                    anchors.centerIn: parent
                    spacing: 2
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: icon
                        color: barColor
                        font.pixelSize: 16
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: value + suffix
                        color: root.walForeground
                        font.pixelSize: 14
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: label
                color: root.walColor8
                font.pixelSize: 11
                font.family: "JetBrainsMono Nerd Font"
            }
        }
    }

    component PowerBtn: Rectangle {
        property string icon
        property color iconColor
        property string cmd
        width: 40
        height: 40
        radius: 10
        color: powerMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
        Behavior on color { ColorAnimation { duration: 150 } }
        Text {
            anchors.centerIn: parent
            text: icon
            color: iconColor
            font.pixelSize: 18
            font.family: "JetBrainsMono Nerd Font"
        }
        MouseArea {
            id: powerMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: cmdProc.running = true
        }
        Process {
            id: cmdProc
            command: ["bash", "-c", cmd]
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            var hours = now.getHours()
            var minutes = now.getMinutes()
            var seconds = now.getSeconds()
            var ampm = hours >= 12 ? 'PM' : 'AM'
            hours = hours % 12
            hours = hours ? hours : 12
            var h = hours < 10 ? '0' + hours : hours
            var m = minutes < 10 ? '0' + minutes : minutes
            var s = seconds < 10 ? '0' + seconds : seconds
            timeDisplay.text = h + ':' + m + ':' + s + ' ' + ampm
            
            if (dashboard.currentDay !== now.getDate()) {
                dashboard.currentDay = now.getDate()
                dashboard.currentMonth = now.getMonth()
                dashboard.currentYear = now.getFullYear()
            }
        }
    }

    Timer {
        interval: 2000
        running: root.dashboardVisible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!cpuProc.running) cpuProc.running = true
            if (!tempProc.running) tempProc.running = true
            if (!ramProc.running) ramProc.running = true
            if (!diskProc.running) diskProc.running = true
            if (!batProc.running) batProc.running = true
            if (!batStatusProc.running) batStatusProc.running = true
            if (!volProc.running) volProc.running = true
            if (!brightProc.running) brightProc.running = true
            if (!uptimeProc.running) uptimeProc.running = true
            if (!updateProc.running) updateProc.running = true
            if (!netProc.running) netProc.running = true
        }
    }

    Process { id: cpuProc; command: ["bash", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print int($2 + $4)}'"]; stdout: SplitParser { onRead: data => dashboard.cpuVal = parseInt(data) || 0 } }
    Process { 
        id: tempProc; 
        command: ["bash", "-c", "t=$(sensors 2>/dev/null | awk '/(Tctl|Package id 0|Core 0)/ {print $2}' | tr -d '+°C' | head -n1 | awk '{print int($1)}'); [ -z \"$t\" ] && t=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | sort -nr | head -n1 | awk '{print int($1/1000)}'); echo ${t:-0}"]
        stdout: SplitParser { onRead: data => dashboard.tempVal = parseInt(data) || 0 } 
    }
    Process { id: ramProc; command: ["bash", "-c", "free | awk '/Mem:/ {printf \"%.0f\", $3/$2*100}'"]; stdout: SplitParser { onRead: data => dashboard.ramVal = parseInt(data) || 0 } }
    Process { id: diskProc; command: ["bash", "-c", "df / | awk 'NR==2 {gsub(/%/,\"\"); print $5}'"]; stdout: SplitParser { onRead: data => dashboard.diskVal = parseInt(data) || 0 } }
    Process { 
        id: batProc; command: ["bash", "-c", "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 100"]
        stdout: SplitParser { onRead: data => { dashboard.batVal = parseInt(data) || 100 } }
    }
    Process {
        id: batStatusProc
        command: ["bash", "-c", "upower -i $(upower -e | grep 'BAT') | grep -E 'state|time to' | awk -F': +' '{print $2}' | xargs echo"]
        stdout: SplitParser {
            onRead: data => {
                var output = data.trim().split(" ");
                var status = output[0];
                var timeStr = (output.length >= 3) ? output[1] + " " + output[2] : "";
                var cap = dashboard.batVal;
                if (status === "charging") {
                    batStatus.text = "Charging" + (timeStr ? " (" + timeStr + " to full)" : "");
                    batIcon.text = "󰂄"; batIcon.color = root.walColor2;
                } else {
                    if (cap >= 90) batIcon.text = "󰁹"; else if (cap >= 80) batIcon.text = "󰂂"; else if (cap >= 70) batIcon.text = "󰂁"; else if (cap >= 60) batIcon.text = "󰂀"; else if (cap >= 50) batIcon.text = "󰁿"; else if (cap >= 40) batIcon.text = "󰁾"; else if (cap >= 30) batIcon.text = "󰁽"; else if (cap >= 20) batIcon.text = "󰁼"; else if (cap >= 10) batIcon.text = "󰁻"; else batIcon.text = "󰁺";
                    if (status === "fully-charged" || status === "full") batStatus.text = "Fully charged";
                    else batStatus.text = "Discharging" + (timeStr ? " (" + timeStr + " left)" : "");
                }
            }
        }
    }
    Process { id: volProc; command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf \"%.0f\", $2*100}'"]; stdout: SplitParser { onRead: data => dashboard.volVal = parseInt(data) || 0 } }
    Process { id: brightProc; command: ["bash", "-c", "brightnessctl -m | awk -F, '{gsub(/%/,\"\"); print $4}'"]; stdout: SplitParser { onRead: data => dashboard.brightVal = parseInt(data) || 100 } }
    Process { id: uptimeProc; command: ["bash", "-c", "uptime -p"]; stdout: SplitParser { onRead: data => uptimeText.text = data.trim() } }
    Process { id: updateProc; command: ["bash", "-c", "core=$(checkupdates 2>/dev/null | wc -l); aur=$(yay -Qua 2>/dev/null | wc -l); echo $((core + aur))"]; stdout: SplitParser { onRead: data => { dashboard.updateVal = parseInt(data.trim()) || 0; } } }
    Process {
        id: netProc
        command: ["bash", "-c", "IFACE=$(ip route | awk '/default/ {print $5}' | head -n1); if [ -z \"$IFACE\" ]; then echo \"0 KB/s|0 KB/s\"; exit; fi; R1=$(cat /sys/class/net/$IFACE/statistics/rx_bytes); T1=$(cat /sys/class/net/$IFACE/statistics/tx_bytes); sleep 1; R2=$(cat /sys/class/net/$IFACE/statistics/rx_bytes); T2=$(cat /sys/class/net/$IFACE/statistics/tx_bytes); RB=$((R2-R1)); TB=$((T2-T1)); awk -v r=$RB -v t=$TB 'BEGIN { if (r < 1024) printf \"0 KB/s|\"; else if (r < 1048576) printf \"%.0f KB/s|\", r/1024; else printf \"%.1f MB/s|\", r/1048576; if (t < 1024) printf \"0 KB/s\"; else if (t < 1048576) printf \"%.0f KB/s\", t/1024; else printf \"%.1f MB/s\", t/1048576; }'"]
        stdout: SplitParser { onRead: d => { let p = d.trim().split("|"); if(p.length === 2) { dashboard.netDown = p[0]; dashboard.netUp = p[1]; } } }
    }
}
