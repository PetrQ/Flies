import QtQuick 2.10
import QtQuick.Window 2.10
import QtQuick.Controls 2.15
import flie.components 1.0

ApplicationWindow   {
    id: root
    property alias columns: myGrid.columns
    property alias rows:    myGrid.rows
    property int   flieCapacity:  5 // default val
    property int   determination: 5 // default val
    property int   autoAddFlies: 0

    width:  myGrid.width < Screen.desktopAvailableWidth ? myGrid.width  :  Screen.desktopAvailableWidth
    height: myGrid.height + menuBar.height < Screen.desktopAvailableHeight ? myGrid.height + menuBar.height:
                                                            Screen.desktopAvailableHeight - 25

    menuBar: MenuBar {
        focus: false
        Menu {
            title: qsTr("&Управление")
            Action { text: qsTr("&Перезапустить")
                onTriggered: restart()
            }
            Action { text: qsTr("&Очистить")
                onTriggered: clear()
            }
            Action { text: qsTr("&Отчет")
                onTriggered: {
                    scroll.pause = true;
                    popupReport.open()
                }
            }
            MenuSeparator { }
            Action { text: qsTr("&Закрыть")
                onTriggered: root.close()
            }
        }

        Menu {
            title: qsTr("&Помощь")
            Action { text: qsTr("&Навигация")
                onTriggered: popupHelp.open()
            }
            MenuSeparator { }
            Action { text: qsTr("&О программе...")
                onTriggered: popupAbout.open()
            }
        }
    }

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

        onFocusChanged: focus ? console.log("FOCUS RETURN") : console.log("FOCUS LOSE")

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
                        onDoubleClicked: {

                            if(isFull) {
                                popupWarning.open()
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
                            Flie.isDie.connect(flieDie);
                        }
                    }
                }

                Component.onCompleted: generate();
            }
        }
    }

    PopupCustom {
        id: popupHelp

        width:   600
        height:  250
        radius: 2
        textBold: false
        textHAlignment: Text.AlignLeft

        contentText: qsTr(" Двойной клик в ячейке - добавление насекомого. \r\n Пробел - пауза. \r\n Скролинг окна - мышью. \r\n Клик на насекомом - окно мониторинга его параметров.")
    }

    PopupCustom {
        id: popupAbout
        contentText: qsTr("Develop by Kusotskiy Petr \r\n kusotskiy@gmail.com.")
    }

    PopupCustom {
        id: popupWarning
        contentText: qsTr("Добавление невозможно. \r\n В секторе максимальное \r\n количество насекомых.")
    }

    PopupCustom {
        id: popupReport
        radius: 2

        property real calcHeight: reportColumn.height + topPadding + bottomPadding + btn.height

        width:  reportColumn.width  + 20 + leftPadding + rightPadding
        height: (root.height - 100) < calcHeight ? root.height - 100 : calcHeight
        opacity: 0.9
        focus: true
        rightPadding: 4

        contentItem: Item{
            id: frame
            Button{
                id: btn
                text: "Закрыть"
                anchors.right: parent.right

                anchors.rightMargin: 10
                onClicked: popupReport.close()
            }

            Flickable {
                id: flicflic
                anchors.top: btn.bottom
                anchors.bottom: frame.bottom
                anchors.left: frame.left
                anchors.right: frame.right

                contentHeight: reportColumn.height
                clip: true

                Column{
                    id: reportColumn
                    padding: 4
                    rightPadding: 10
                }

                ScrollBar.vertical: ScrollBar{
                    property real workHeight : frame.height - btn.height

                    size: workHeight/reportColumn.height
                    anchors.top: parent.top
                    height: workHeight
                }
            }
        }

        onOpened: {

            const myMap = new Map();

            for(var child in myGrid.children)
            {
                if(myGrid.children[child].objectName === "FlieLogic")
                {
                    if(!myMap.has(myGrid.children[child].cellId))
                        myMap.set(myGrid.children[child].cellId, [])

                    var string = "Пробег " + myGrid.children[child].path.toString()
                               + " п.  Возраст " + myGrid.children[child].age.toString()
                               + " с.  Скорость "
                               + (Math.round(myGrid.children[child].path*100/myGrid.children[child].age)/100).toString()
                               + "п/с."

                    myMap.get(myGrid.children[child].cellId).push(string);
                }
            }

            for (var i = 0; i < myMap.size; ++i) {
                if(myMap.has(i)){
                    var component = Qt.createComponent("ReportString.qml");
                    component.createObject(reportColumn, { text: "Сектор " + (i + 1) + ":" });
                }

                for(var strId in myMap.get(i)){
                    component = Qt.createComponent("ReportString.qml");
                    component.createObject(reportColumn, { text: myMap.get(i)[strId] });
                }
            }
        }

        onClosed: {
            onClosed: scroll.pause = false;

            for(var child1 in reportColumn.children){
                if(reportColumn.children[child1].objectName === "ReportString")
                    reportColumn.children[child1].destroy()
            }
        }
    }

    function clear(){
        for(var child in myGrid.children)
            if(myGrid.children[child].objectName === "FlieLogic"
                    && myGrid.children[child].corpse)
                myGrid.children[child].destroy()
    }

    function restart(){
        for(var child in myGrid.children){
            if(myGrid.children[child].objectName === "FlieLogic"){
                myGrid.children[child].destroy()
            }

            if(myGrid.children[child].objectName.includes("Cell"))
                myGrid.children[child].content = 0;
        }

        generate();
    }

    function generate(){
        for(var i = 0; i < root.autoAddFlies; i++){
            do{
            var ind = Math.round(Math.random() * (root.rows * root.columns -1 ));
            }while(repeater.itemAt(ind).isFull)

            var cell = repeater.itemAt(ind)

            cell.content++;
            var component = Qt.createComponent("Flie.qml");
            var point = repeater.mapToItem(myGrid, cell.x + cell.width/2 , cell.y + cell.height/2 )

            var Flie = component.createObject(
                            myGrid, { flieStartPos: point
                                   ,fieldSize: repeater.count
                                   ,cell: cell
                                   ,determination: root.determination
                                   });
            Flie.startMigrate.connect(migrate);
            Flie.isDie.connect(flieDie);
        }
    }

    function migrate(oldCell, newCell){
        if(repeater.itemAt(oldCell).content >= 0) repeater.itemAt(oldCell).content--
        repeater.itemAt(newCell).content++
//        console.log("migrate"
//                    ,oldCell, repeater.itemAt(oldCell).content
//                    ,newCell, repeater.itemAt(newCell).content)
    }

    function flieDie(cellId){
        repeater.itemAt(cellId).content++
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
