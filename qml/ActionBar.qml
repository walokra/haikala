import QtQuick 2.1
import Sailfish.Silica 1.0

Item {
    id: root;
    anchors { left: parent.left; right: parent.right; bottom: parent.bottom; }
    z: 1;
    visible: true;
    height: toolbar.height + poweredLbl.height;

    property bool shown: true;

    onShownChanged: {
        if (shown) {
            opacity = 1;
            visible = true;
            flickable.anchors.bottom = root.top;
        } else {
            opacity = 0;
            visible = false;
            flickable.anchors.bottom = root.bottom;
        }
    }

    property Flickable flickable;

    Toolbar {
        id: toolbar;

        function setAnchors() {
            //console.debug("toolbar.setAnchors");
            anchors.top = undefined;
            anchors.bottom = parent.bottom;
        }
    }

    Label {
        id: poweredLbl;
        anchors { bottom: parent.bottom; }
        anchors.horizontalCenter: parent.horizontalCenter;
        anchors.leftMargin: Theme.paddingMedium;
        anchors.rightMargin: Theme.paddingMedium;
        anchors.bottomMargin: Theme.paddingSmall;
        anchors.topMargin: Theme.paddingMedium;
        font.pixelSize: Theme.fontSizeTiny;
        color: constants.colorHilightSecondary;
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
        text: qsTr("powered by high.fi");
        opacity: 0.7;
    }

    //Behavior on opacity { FadeAnimation { duration: 10000; } }
    //Behavior on height { NumberAnimation { easing.type: Easing.Linear; } }

    Connections {
        target: flickable
        onFlickingVerticallyChanged: {
            //console.debug("onFlickingVerticallyChanged, velocity=" + flickable.verticalVelocity);
            if (flickable.atYBeginning) {
                actionBar.shown = true;
            }

            if (flickable.verticalVelocity < 0) {
                actionBar.shown = true;
            }
            if (flickable.verticalVelocity > 0) {
                actionBar.shown = false;
            }
        }
    }

    Component.onCompleted: {
        toolbar.setAnchors();
    }
}
