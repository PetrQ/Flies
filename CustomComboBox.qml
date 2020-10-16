import QtQuick 2.0
import QtQuick.Controls 2.1

Rectangle {
    id: main
    width: childrenRect.width
    implicitHeight: 30

    property var model;
    property int currentIndex: 0

    Rectangle{
        color: "transparent"
        border.color: "grey"
        border.width: 1
        width:  childrenRect.width
        height: childrenRect.height


        Row{
            id: rowLo
            height: Math.max(columnLo.height, itemText.height)

            Label {
                id: itemText
                width: 200 // можно сделать функцию выбирающую максимум из модели
                horizontalAlignment: Text.AlignHCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            Column{
                id: columnLo
                width: childrenRect.width

                Image {
                    width: main.height/2  + 4
                    height: main.height/2 + 4
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/pic/arrow64.png"
                    MouseArea{
                        anchors.fill:parent
                        onClicked: if(currentIndex >0) currentIndex -= 1
                    }

                }
                Image {
                    width: main.height/2   + 4
                    height: main.height/2  + 4
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/pic/arrow64.png"
                    rotation: 180
                    MouseArea{
                        anchors.fill:parent
                        onClicked: if(currentIndex < (model.length - 1)) currentIndex += 1
                    }
                }
            }

            Rectangle{
                id: rightMerg
                height: 1
                width: 10
                color: "transparent"
            }
        }
    }

    onCurrentIndexChanged: {
        itemText.text = model[currentIndex]
    }

    Component.onCompleted: {
        itemText.text = model[currentIndex]
    }

}
