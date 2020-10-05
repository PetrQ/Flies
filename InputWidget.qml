import QtQuick 2.10
import QtQuick.Controls 2.1

Row{

    property alias name: label.text
    property alias value: control.value

    spacing: 6

    height: 40

    Text {
        id:label
        text: qsTr("some text");
    }

    SpinBox {
        id: control
        editable: true
    }

}

