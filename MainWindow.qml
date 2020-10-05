import QtQuick 2.10
import QtQuick.Window 2.10
import QtQuick.Controls 1.4

ApplicationWindow   {

    width:  myGrid.width < Screen.desktopAvailableWidth ? myGrid.width :
                                                          Screen.desktopAvailableWidth
    height: myGrid.height < Screen.desktopAvailableHeight ? myGrid.height :
                                                            Screen.desktopAvailableHeight - 25
    ScrollView  {
        id: scroll
        anchors.fill: parent

        horizontalScrollBarPolicy : Qt.ScrollBarAsNeeded
        verticalScrollBarPolicy :   Qt.ScrollBarAsNeeded

        Grid{
            id: myGrid
//            padding: 5

            //                anchors.centerIn: orange
            columns : 5
            rows : 5

            onXChanged: console.log("x",x)
            Repeater {
                model: 50
                delegate : Rectangle{
                    width: 100
                    height: 100
                    border.width: 3
                    border.color: "red"
                    color: "blue"
                }
            }

            onWidthChanged: console.log("gr",myGrid.width, scroll.width, x)
        }

    }

    onWidthChanged: {
        if(scroll.width > myGrid.width){
            myGrid.x = (scroll.width - myGrid.width)/2
        }else
            myGrid.x = 0
                    console.log("x", myGrid.x, myGrid.width)
    }
    onHeightChanged: {
        if(scroll.height > myGrid.height){
            myGrid.y = (scroll.height - myGrid.height)/2
        }else
            myGrid.y = 0
                    console.log("y", myGrid.y, myGrid.height)
    }

}
