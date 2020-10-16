import QtQuick 2.0
import flie.components 1.0

FlieLogic{
    id: logic
    pause: scroll.pause
    z: 10

    property alias flieX: sprite.x
    property alias flieY: sprite.y

    fliePic: AnimatedSprite {
        id: sprite
        width: frameWidth/2
        height: frameHeight/2

        source: "qrc:/pic/ladybug_walk_atlas.png"
        interpolate: false
        frameCount: 15
        frameWidth: 94
        frameHeight: 104
        frameDuration: logic.scurryIntvl/2
        paused: logic.pause

        MouseArea{
            anchors.fill: parent
            onClicked: {
                statistic.visible = !statistic.visible
            }
        }

    }

    AnimatedSprite {

        x: sprite.x
        y: sprite.y
        visible: !sprite.visible
        rotation: sprite.rotation

        width: frameWidth/1.6
        height: frameHeight/1.6

        source: "qrc:/pic/ladybug_fly_atlas.png"
        interpolate: false
        frameCount: 10
        frameWidth: 216
        frameHeight: 106
        frameDuration: logic.scurryIntvl/10
        paused: logic.pause

        MouseArea{
            anchors.fill: parent
            onClicked: {
                statistic.visible = !statistic.visible
            }
        }
    }

    Rectangle {
        id: statistic
        width: 115
        height: 70
        opacity: 0.7
        radius: 10
        x: sprite.x - 100
        y: sprite.y - 70

        border.color: "lightblue"
        border.width: 2

        visible: false
        color: "lightgrey"

        Item{
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 6
            anchors.leftMargin: 5

            Column{

                Text {
                    text: qsTr("Скорость  "+logic.speed+" п/с")
                    font.pointSize: 8
                }
                Text {
                    text: qsTr("Пробег  "+logic.path+" п")
                    font.pointSize: 8
                }
                Text {
                    text: qsTr("Возрост  "+logic.age+" c")
                    font.pointSize: 8
                }
            }
        }

    }


}
