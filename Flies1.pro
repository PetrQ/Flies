QT += quick
CONFIG += c++11

SOURCES += \
        FlieLogic.cpp \
        main.cpp

RESOURCES += qml.qrc \
    icons.qrc

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    README.md

HEADERS += \
    FlieLogic.h

STATECHARTS += \
    Cicle.scxml
