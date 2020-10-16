import QtQuick 2.10
import QtQuick.Controls 2.1

Frame{
    property alias name:  label.text
    property alias value: control.value
    property alias to:    control.to
    property alias from:  control.from

    property bool spring : false

    background: Rectangle {
        color: "white"
        border.color: "lightgrey"
        radius: 2
    }

    Row{
        spacing: 6

        Text {
            id:label
            text: qsTr("some text");
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle{
            id: springRect
            height: 1
            width: 0
            color: "transparent"
        }

        SpinBox {
            id: control
            editable: true
            value: to/2
            anchors.verticalCenter: parent.verticalCenter

            validator: IntValidator {
                locale: control.locale.name
                bottom: Math.min(control.from, control.to)
                top:    Math.max(control.from, control.to)
            }
        }
    }

    onWidthChanged: if(spring && contentWidth){
                        springRect.width = width - label.width - control.width - 40
                    }

}


