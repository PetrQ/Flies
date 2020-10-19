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
