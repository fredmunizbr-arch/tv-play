import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtMultimedia

ApplicationWindow {
    id: window
    width: 1600
    height: 960
    minimumWidth: 1180
    minimumHeight: 760
    visible: true
    title: "TV PLAYOUT | Broadcast Playout 0.2"
    color: "#10151d"

    property int programIndex: -1
    property int selectedIndex: -1
    property int previewIndex: -1
    property bool autoAdvance: true
    property string statusText: "PRONTO"
    property string currentFile: "Nenhum vídeo no ar"
    property string previewFile: "Nenhum vídeo no Preview"

    ListModel { id: playlist }

    function fileNameFromUrl(url) {
        const path = decodeURIComponent(url.toString())
        const clean = path.split("?")[0]
        const parts = clean.split("/")
        return parts[parts.length - 1] || clean
    }

    function addFiles(urls) {
        for (let i = 0; i < urls.length; ++i) {
            const url = urls[i]
            playlist.append({
                "mediaUrl": url,
                "fileName": fileNameFromUrl(url),
                "duration": "--:--"
            })
        }
        if (selectedIndex < 0 && playlist.count > 0)
            selectedIndex = 0
        statusText = playlist.count + " ITEM(NS) NA PLAYLIST"
    }

    function previewAt(index) {
        if (index < 0 || index >= playlist.count)
            return
        selectedIndex = index
        previewIndex = index
        previewFile = playlist.get(index).fileName
        previewPlayer.stop()
        previewPlayer.source = playlist.get(index).mediaUrl
        previewPlayer.play()
        statusText = "PREVIEW CARREGADO"
    }

    function takePreview() {
        if (previewIndex < 0 || previewIndex >= playlist.count)
            return
        const item = playlist.get(previewIndex)
        programPlayer.stop()
        programPlayer.source = item.mediaUrl
        programIndex = previewIndex
        selectedIndex = previewIndex
        currentFile = item.fileName
        previewPlayer.pause()
        programPlayer.play()
        statusText = "NO AR"
    }

    function playProgramAt(index) {
        if (index < 0 || index >= playlist.count)
            return
        selectedIndex = index
        programIndex = index
        currentFile = playlist.get(index).fileName
        programPlayer.stop()
        programPlayer.source = playlist.get(index).mediaUrl
        programPlayer.play()
        statusText = "NO AR"
    }

    function playNext() {
        if (programIndex + 1 < playlist.count) {
            playProgramAt(programIndex + 1)
        } else {
            statusText = "FIM DA PLAYLIST"
        }
    }

    function removeSelected() {
        const idx = selectedIndex
        if (idx < 0 || idx >= playlist.count)
            return

        const wasProgram = idx === programIndex
        const wasPreview = previewPlayer.source.toString() === playlist.get(idx).mediaUrl.toString()

        if (wasProgram) {
            programPlayer.stop()
            programPlayer.source = ""
            currentFile = "Nenhum vídeo no ar"
            programIndex = -1
            statusText = "PROGRAMA PARADO"
        } else if (idx < programIndex) {
            programIndex--
        }

        if (wasPreview) {
            previewPlayer.stop()
            previewPlayer.source = ""
            previewFile = "Nenhum vídeo no Preview"
            previewIndex = -1
        } else if (idx < previewIndex) {
            previewIndex--
        }

        playlist.remove(idx)

        if (playlist.count === 0) {
            selectedIndex = -1
        } else {
            selectedIndex = Math.min(idx, playlist.count - 1)
        }
    }

    function clearPlaylist() {
        programPlayer.stop()
        previewPlayer.stop()
        programPlayer.source = ""
        previewPlayer.source = ""
        playlist.clear()
        selectedIndex = -1
        previewIndex = -1
        programIndex = -1
        currentFile = "Nenhum vídeo no ar"
        previewFile = "Nenhum vídeo no Preview"
        statusText = "PRONTO"
    }

    function formatTime(ms) {
        if (ms < 0 || !isFinite(ms))
            return "00:00"
        const total = Math.floor(ms / 1000)
        const h = Math.floor(total / 3600)
        const m = Math.floor((total % 3600) / 60)
        const s = total % 60
        const pad = n => n.toString().padStart(2, "0")
        return h > 0 ? pad(h) + ":" + pad(m) + ":" + pad(s) : pad(m) + ":" + pad(s)
    }

    MediaPlayer {
        id: previewPlayer
        audioOutput: AudioOutput { muted: true }
        videoOutput: previewVideo
        onMediaStatusChanged: {
            if (mediaStatus === MediaPlayer.InvalidMedia)
                statusText = "ERRO NO PREVIEW"
        }
    }

    MediaPlayer {
        id: programPlayer
        audioOutput: AudioOutput { volume: volumeSlider.value }
        videoOutput: programVideo
        onPlaybackStateChanged: {
            if (playbackState === MediaPlayer.PlayingState)
                statusText = "NO AR"
            else if (playbackState === MediaPlayer.PausedState)
                statusText = "PAUSADO"
        }
        onMediaStatusChanged: {
            if (mediaStatus === MediaPlayer.EndOfMedia && autoAdvance)
                playNext()
            else if (mediaStatus === MediaPlayer.InvalidMedia)
                statusText = "ERRO AO ABRIR MÍDIA"
        }
        onDurationChanged: {
            if (programIndex >= 0 && programIndex < playlist.count)
                playlist.setProperty(programIndex, "duration", formatTime(duration))
        }
    }

    FileDialog {
        id: mediaDialog
        title: "Adicionar vídeos à playlist"
        fileMode: FileDialog.OpenFiles
        nameFilters: ["Vídeos (*.mp4 *.mov *.mkv *.m4v *.avi *.mpg *.mpeg)", "Todos os arquivos (*)"]
        onAccepted: addFiles(selectedFiles)
    }

    Rectangle {
        anchors.fill: parent
        color: "#10151d"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 13

            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                ColumnLayout {
                    spacing: 1
                    Label {
                        text: "TV <font color='#42b7ff'>PLAYOUT</font>"
                        textFormat: Text.RichText
                        color: "white"
                        font.pixelSize: 27
                        font.bold: true
                    }
                    Label {
                        text: "BROADCAST PLAYBACK SYSTEM  •  VERSION 0.2"
                        color: "#8290a3"
                        font.pixelSize: 10
                        font.letterSpacing: 1.5
                    }
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    radius: 5
                    color: statusText === "NO AR" ? "#173d32" : "#263344"
                    border.color: statusText === "NO AR" ? "#286b55" : "#3a4b60"
                    implicitWidth: statusLabel.implicitWidth + 24
                    implicitHeight: 34
                    Label {
                        id: statusLabel
                        anchors.centerIn: parent
                        text: "● " + statusText
                        color: statusText === "NO AR" ? "#70e0b0" : "#c4d0df"
                        font.pixelSize: 11
                        font.bold: true
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 14

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 10

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumHeight: 250
                            Layout.preferredWidth: 1.35
                            radius: 8
                            color: "#05080d"
                            border.color: "#7c2734"
                            clip: true

                            VideoOutput {
                                id: programVideo
                                anchors.fill: parent
                                fillMode: VideoOutput.PreserveAspectFit
                            }

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.margins: 10
                                radius: 3
                                color: "#b51f35"
                                width: 91
                                height: 25
                                Label {
                                    anchors.centerIn: parent
                                    text: "● PROGRAM"
                                    color: "white"
                                    font.bold: true
                                    font.pixelSize: 10
                                }
                            }

                            Label {
                                anchors.centerIn: parent
                                visible: programPlayer.source.toString() === ""
                                text: "TV PLAYOUT\n\nAGUARDANDO CONTEÚDO"
                                horizontalAlignment: Text.AlignHCenter
                                color: "#68778b"
                                font.pixelSize: 17
                                font.bold: true
                            }

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: 35
                                color: "#bb080d14"
                                Label {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 11
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: currentFile
                                    color: "white"
                                    elide: Text.ElideMiddle
                                    width: parent.width - 22
                                    font.pixelSize: 11
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumHeight: 250
                            Layout.preferredWidth: 1
                            radius: 8
                            color: "#05080d"
                            border.color: "#277b9c"
                            clip: true

                            VideoOutput {
                                id: previewVideo
                                anchors.fill: parent
                                fillMode: VideoOutput.PreserveAspectFit
                            }

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.margins: 10
                                radius: 3
                                color: "#087da8"
                                width: 82
                                height: 25
                                Label {
                                    anchors.centerIn: parent
                                    text: "PREVIEW"
                                    color: "white"
                                    font.bold: true
                                    font.pixelSize: 10
                                }
                            }

                            Label {
                                anchors.centerIn: parent
                                visible: previewPlayer.source.toString() === ""
                                text: "PRÉ-VISUALIZAÇÃO\n\nSELECIONE UM CLIPE"
                                horizontalAlignment: Text.AlignHCenter
                                color: "#68778b"
                                font.pixelSize: 14
                                font.bold: true
                            }

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: 35
                                color: "#bb080d14"
                                Label {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 11
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: previewFile
                                    color: "white"
                                    elide: Text.ElideMiddle
                                    width: parent.width - 22
                                    font.pixelSize: 10
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Button {
                            text: "▶  PLAY"
                            highlighted: true
                            onClicked: programIndex < 0 ? playProgramAt(selectedIndex >= 0 ? selectedIndex : 0) : programPlayer.play()
                        }
                        Button {
                            text: "Ⅱ  PAUSE"
                            onClicked: programPlayer.pause()
                        }
                        Button {
                            text: "■  STOP"
                            onClicked: { programPlayer.stop(); statusText = "PARADO" }
                        }
                        Button {
                            text: "NEXT  »"
                            onClicked: playNext()
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: formatTime(programPlayer.position) + " / " + formatTime(programPlayer.duration)
                            color: "#c5d0df"
                            font.pixelSize: 12
                            font.family: "monospace"
                        }
                    }

                    Slider {
                        Layout.fillWidth: true
                        from: 0
                        to: Math.max(1, programPlayer.duration)
                        value: programPlayer.position
                        onMoved: programPlayer.position = value
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Button {
                            text: "CARREGAR PREVIEW"
                            enabled: selectedIndex >= 0 && selectedIndex < playlist.count
                            onClicked: previewAt(selectedIndex)
                        }
                        Button {
                            text: "Ⅱ  PAUSAR PREVIEW"
                            enabled: previewPlayer.source.toString() !== ""
                            onClicked: previewPlayer.pause()
                        }
                        Item { Layout.fillWidth: true }
                        Button {
                            text: "TAKE  →  PROGRAM"
                            highlighted: true
                            enabled: previewPlayer.source.toString() !== ""
                            onClicked: takePreview()
                        }
                    }
                }

                ColumnLayout {
                    Layout.preferredWidth: 410
                    Layout.minimumWidth: 340
                    Layout.fillHeight: true
                    spacing: 10

                    Rectangle {
                        Layout.fillWidth: true
                        height: 42
                        radius: 6
                        color: "#1b2634"
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 8
                            Label {
                                text: "PLAYLIST"
                                color: "white"
                                font.bold: true
                                font.pixelSize: 13
                            }
                            Item { Layout.fillWidth: true }
                            Label {
                                text: playlist.count + " ITENS"
                                color: "#91a1b5"
                                font.pixelSize: 10
                            }
                            Button {
                                text: "+ ADICIONAR"
                                onClicked: mediaDialog.open()
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 6
                        color: "#151e29"
                        border.color: "#263344"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 0

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.leftMargin: 8
                                Layout.rightMargin: 8
                                height: 30
                                Label { text: "Nº"; color: "#8290a3"; Layout.preferredWidth: 30; font.pixelSize: 10 }
                                Label { text: "ARQUIVO"; color: "#8290a3"; Layout.fillWidth: true; font.pixelSize: 10 }
                                Label { text: "DURAÇÃO"; color: "#8290a3"; font.pixelSize: 10 }
                            }
                            Rectangle { Layout.fillWidth: true; height: 1; color: "#2a3748" }

                            ListView {
                                id: playlistView
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                model: playlist
                                currentIndex: selectedIndex
                                delegate: Rectangle {
                                    required property int index
                                    required property string fileName
                                    required property string duration
                                    width: playlistView.width
                                    height: 46
                                    color: index === window.selectedIndex ? "#203d59" : (index % 2 ? "#17212d" : "#151e29")
                                    border.width: index === window.programIndex ? 1 : 0
                                    border.color: "#b51f35"

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8
                                        Label {
                                            text: (index + 1).toString().padStart(2, "0")
                                            color: "#8290a3"
                                            Layout.preferredWidth: 30
                                            font.pixelSize: 11
                                        }
                                        Label {
                                            text: (index === window.programIndex ? "● " : "") + fileName
                                            color: index === window.selectedIndex ? "#ffffff" : "#c4cfdd"
                                            Layout.fillWidth: true
                                            elide: Text.ElideMiddle
                                            font.pixelSize: 11
                                        }
                                        Label {
                                            text: duration
                                            color: "#91a1b5"
                                            font.pixelSize: 10
                                            font.family: "monospace"
                                        }
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: selectedIndex = index
                                        onDoubleClicked: previewAt(index)
                                    }
                                }
                                Label {
                                    anchors.centerIn: parent
                                    visible: playlist.count === 0
                                    text: "Playlist vazia\nClique em + ADICIONAR para importar vídeos"
                                    color: "#748398"
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pixelSize: 12
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        CheckBox {
                            text: "Auto Play"
                            checked: autoAdvance
                            onToggled: autoAdvance = checked
                            palette.text: "#d2dbe7"
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: "VOLUME"
                            color: "#8290a3"
                            font.pixelSize: 10
                        }
                        Slider {
                            id: volumeSlider
                            Layout.preferredWidth: 115
                            from: 0
                            to: 1
                            value: 0.8
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Button {
                            text: "REMOVER SELECIONADO"
                            enabled: selectedIndex >= 0 && playlist.count > 0
                            onClicked: removeSelected()
                        }
                        Item { Layout.fillWidth: true }
                        Button {
                            text: "LIMPAR"
                            onClicked: clearPlaylist()
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 27
                radius: 4
                color: "#151e29"
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    Label { text: "TV PLAYOUT  •  PROTÓTIPO 0.2"; color: "#8290a3"; font.pixelSize: 9 }
                    Item { Layout.fillWidth: true }
                    Label { text: "PREVIEW / PROGRAM INDEPENDENTES  •  SAÍDA LOCAL"; color: "#70bde0"; font.pixelSize: 9 }
                }
            }
        }
    }
}
