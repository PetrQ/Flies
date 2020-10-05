import QtQuick 2.0

Rectangle {

//    property alias model: listView.model
    id: main

    height:  40
    width: childrenRect.width

    property var model;
    property int currentIndex: 0

    Row{
        Text {
            id: text
            width: 120
        }

        Column{
            Rectangle{
                width: main.height/2
                height: main.height/2
                color: "red"
                MouseArea{
                    anchors.fill:parent
                    onClicked: if(currentIndex >0) currentIndex -= 1
                }

            }
            Rectangle{
                width: main.height/2
                height: main.height/2
                color: "green"
                MouseArea{
                    anchors.fill:parent
                    onClicked: if(currentIndex < (model.length - 1)) currentIndex += 1
                }
            }
        }
    }

    onCurrentIndexChanged: {
        text.text = model[currentIndex]
    }

    Component.onCompleted: {
        text.text = model[currentIndex]
    }

}
