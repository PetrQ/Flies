import QtQuick 2.10
import QtQuick.Window 2.10
import QtQuick.Controls 2.15
import flie.components 1.0

Popup {
    id: popupReport
    x:  (parent.width - width)/2
    y:  (parent.height - height)/2
    modal: false
    focus: false
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    property alias radius: background.radius
    property alias contentText: content.text
    property alias textBold: content.font.bold
    property alias textHAlignment: content.horizontalAlignment

    contentItem:
        Rectangle{
        color: "transparent"

        Text {
            id: content
            anchors.top: parent.top
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment : Text.AlignHCenter

            font{
                bold: true
                pointSize : 12
            }
        }

        Button{
            id:closeBtn
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            text:"OK"
            onPressed: popupReport.close();

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
        id: background
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
