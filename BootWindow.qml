import QtQuick 2.10
import QtQuick.Window 2.10
import QtQuick.Controls 2.1

Window {
    id: initialize
    visible:  true

    width: 680
    height: 400

    property variant win;  // you can hold this as a reference..

    Column{
        anchors.left:  initialize.top
        anchors.right: initialize.right
        anchors.centerIn: parent

        InputWidget{
            name: qsTr("Размер")
            value: 20
        }

        InputWidget{
            name: qsTr("Мухоемкость")
            value: 20
        }

        Row{
            spacing: 6
            height: 40

            Text {
                id:label
                text: qsTr("Распределение мух");
            }

            CustomComboBox{
                model: [qsTr("Автоматическое"), qsTr("Ручное")]
            }
        }

        InputWidget{
            name: qsTr("Решительность")
            value: 20
        }

        Button{
            id:button
            text: qsTr("Старт")
            background: Rectangle {
                implicitWidth: 100
                implicitHeight: 40
                color: button.down ? "#d6d6d6" : "#f6f6f6"
                border.color: "#26282a"
                border.width: 1
                radius: 4
            }

            onClicked: {
                var component = Qt.createComponent("MainWindow.qml");
                var window = component.createObject(initialize);
                window.show();
                initialize.hide();
            }
        }
    }
}
