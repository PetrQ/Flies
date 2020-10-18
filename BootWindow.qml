import QtQuick 2.10
import QtQuick.Window 2.10
import QtQuick.Controls 2.1

Window {
    id: initializeWindow
    visible:  true

    width: 640
    height: 480

    Frame{
        anchors.centerIn: parent

        background: Rectangle {
            color: "lightgrey"
            radius: 2
        }

        Column{
            anchors.left:  initializeWindow.top
            anchors.right: initializeWindow.right
            anchors.centerIn: parent

            spacing: 20

            InputWidget{
                id: edgeLength
                anchors.left: parent.left
                anchors.right: parent.right
                spring: true
                value: 3

                name: qsTr("Длинна грани поля")
                to: 10
            }

            InputWidget{
                id: capacity
                anchors.left: parent.left
                anchors.right: parent.right
                spring: true

                name: qsTr("Мухоемкость")
                to: 10
            }

            Frame{
                bottomPadding: 20

                background: Rectangle {
                    color: "white"
                    border.color: "lightgrey"
                    radius: 2
                }
                Row{
                    spacing: 10

                    Text {
                        id:label
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("Распределение мух");
                    }

                    CustomComboBox{
                        id: distribution
                        model: [qsTr("Автоматическое"), qsTr("Ручное")]
                    }
                }
            }

            InputWidget{
                id: determination
                anchors.left: parent.left
                anchors.right: parent.right
                spring: true

                name: qsTr("Решительность")
                to: 20
            }

            Button{
                id:button
                text: qsTr("Старт")
                anchors.horizontalCenter: parent.horizontalCenter
                background: Rectangle {
                    implicitWidth: 100
                    implicitHeight: 40
                    color: button.down ? "#d6d6d6" : "#f6f6f6"
                    border.color: "#26282a"
                    border.width: 1
                    radius: 8
                }

                onClicked: {
                    var component = Qt.createComponent("MainWindow.qml");
                    var window = component.createObject(initializeWindow
                                                        ,{  columns: edgeLength.value
                                                           ,rows: edgeLength.value
                                                           ,flieCapacity:  capacity.value
                                                           ,determination: determination.value
                                                           ,autoAddFlies: distribution.currentIndex === 1 ? 0 :
                                                                          edgeLength.value * edgeLength.value * capacity.value / 2
                                                        }
                                                        );
                    window.show();
                    initializeWindow.hide();
                }
            }
        }
    }
}
