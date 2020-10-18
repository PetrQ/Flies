import QtQuick 2.10
import QtQuick.Window 2.10
import QtQuick.Controls 2.1
import flie.components 1.0

Window   {
    id: root
    property alias columns: myGrid.columns
    property alias rows:    myGrid.rows
    property int   flieCapacity:  5 // default val
    property int   determination: 5 // default val
    property int   autoAddFlies: 0

    width:  myGrid.width < Screen.desktopAvailableWidth ? myGrid.width  :
                                                          Screen.desktopAvailableWidth
    height: myGrid.height < Screen.desktopAvailableHeight ? myGrid.height :
                                                          Screen.desktopAvailableHeight - 25


    Flickable  {
        id: scroll
        anchors.fill: parent

        contentWidth: contentItem.childrenRect.width;
        contentHeight: contentItem.childrenRect.height
        property bool pause: false

        focus: true
        Keys.onPressed: {
            if (event.key === Qt.Key_Space) scroll.pause = !scroll.pause
        }

        onFocusChanged: console.log("AAAAAAA!")

        Grid{
            id: myGrid
            objectName:"Container"
            columns: 5
            rows   : 5
            Repeater {
                id: repeater
                objectName: "Repeater"
                model: myGrid.columns * myGrid.rows
                delegate :
                    Rectangle {
                    id:    cell
                    objectName: "Cell"+model.index
                    width:  300
                    height: 300
                    border.width: 3
                    border.color: "lightblue"
                    color: "grey"

                    property int index:   model.index
                    property int content: 0
                    property bool isFull: content >= flieCapacity

                    MouseArea{
                        anchors.fill: parent
                        onClicked: {

                            if(isFull) {
                                popup.open()
                                return;
                            }
                            var point =  mapToItem(myGrid, mouseX, mouseY )

                            cell.content++;
                            var component = Qt.createComponent("Flie.qml");
                            var Flie = component.createObject(
                                            myGrid, { flieStartPos: point
                                                   ,fieldSize: repeater.count
                                                   ,cell: repeater.itemAt(model.index)
                                                   ,determination: root.determination
                                                   });
                            Flie.startMigrate.connect(migrate);
                        }
                    }
                }

                Component.onCompleted: {
                    console.log("REP", count)
                    for(var i = 0; i < root.autoAddFlies; i++){
                        do{
                        var ind = Math.round(Math.random() * (root.rows * root.columns -1 ));
                        }while(repeater.itemAt(ind).isFull)

                        var cell = repeater.itemAt(ind)

                        cell.content++;
                        var component = Qt.createComponent("Flie.qml");
                        var point = mapToItem(myGrid, cell.x + cell.width/2 , cell.y + cell.height/2 )

                        var Flie = component.createObject(
                                        myGrid, { flieStartPos: point
                                               ,fieldSize: repeater.count
                                               ,cell: cell
                                               ,determination: root.determination
                                               });
                        Flie.startMigrate.connect(migrate);

                        console.log(ind, repeater.itemAt(ind).objectName )
                    }
                }
            }
        }
    }

    Popup {
        id: popup
        x:  (parent.width - width)/2
        y:  (parent.height - height)/2
        modal: false
        focus: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        contentItem:
            Rectangle{
            anchors.fill: parent
            color: "transparent"

            Text {

                anchors.top: parent.top
                anchors.topMargin: 30
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment : Text.AlignHCenter

                font{
                    bold: true
                    pointSize : 12
                }

                text: qsTr("Добавление невозможно. \r\n В секторе максимальное \r\n количество насекомых.")
            }

            Button{
                id:closeBtn
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
                text:"OK"
                onPressed: popup.close();

                background: Rectangle {
                    implicitWidth: 100
                    implicitHeight: 40
                    color: closeBtn.down ? "#d6d6d6" : "#f6f6f6"
                    border.color: "#26282a"
                    border.width: 1
                    radius: 8
                }
            }
        }

        background: Rectangle {
            implicitWidth: 300
            implicitHeight: 200
            border.color: "#444"
            border.width: 2

            radius : 20
        }

        onClosed: {
            scroll.focus = true;
        }
    }

    function migrate(oldCell, newCell){
        if(repeater.itemAt(oldCell).content >= 0) repeater.itemAt(oldCell).content--
        repeater.itemAt(newCell).content++
//        console.log("migrate"
//                    ,oldCell, repeater.itemAt(oldCell).content
//                    ,newCell, repeater.itemAt(newCell).content)
    }

    onWidthChanged: {
        if(scroll.width > myGrid.width){
            myGrid.x = (scroll.width - myGrid.width)/2
        }else
            myGrid.x = 0
    }
    onHeightChanged: {
        if(scroll.height > myGrid.height){
            myGrid.y = (scroll.height - myGrid.height)/2
        }else
            myGrid.y = 0
    }


}
