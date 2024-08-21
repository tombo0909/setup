
import sys
from PyQt5 import QtWidgets, QtCore, QtGui

class ResizableRectangle(QtWidgets.QWidget):
    def __init__(self):
        super().__init__()

        self.setGeometry(300, 300, 200, 100)
        self.setAttribute(QtCore.Qt.WA_TranslucentBackground)
        self.setWindowFlags(QtCore.Qt.FramelessWindowHint | QtCore.Qt.WindowStaysOnTopHint | QtCore.Qt.X11BypassWindowManagerHint)

        self.dragging = False
        self.resizing = False
        self.margin = 7  # Ändern um minimale Groesse des Rechtecks und Empfindlichkeit an den Ecken/Kanten zu veraendern 
        self.resize_direction = None

    def mousePressEvent(self, event):
        if event.button() == QtCore.Qt.LeftButton:
            self.detect_resize_direction(event)
            if self.resize_direction:
                self.resizing = True
                self.resize_start_pos = event.globalPos()
                self.resize_start_geometry = self.geometry()
            else:
                self.dragging = True
                self.drag_start_pos = event.globalPos() - self.frameGeometry().topLeft()
            event.accept()

    def mouseMoveEvent(self, event):
        if self.dragging:
            self.move(event.globalPos() - self.drag_start_pos)
            event.accept()
        elif self.resizing:
            self.perform_resize(event)
            event.accept()
        else:
            self.update_cursor_shape(event)

    def mouseReleaseEvent(self, event):
        self.dragging = False
        self.resizing = False
        self.resize_direction = None
        event.accept()

    def detect_resize_direction(self, event):
        rect = self.rect()
        x, y, w, h = rect.x(), rect.y(), rect.width(), rect.height()
        mx, my = event.x(), event.y()

        if mx <= self.margin and my <= self.margin:
            self.resize_direction = 'top_left'
        elif mx >= w - self.margin and my <= self.margin:
            self.resize_direction = 'top_right'
        elif mx <= self.margin and my >= h - self.margin:
            self.resize_direction = 'bottom_left'
        elif mx >= w - self.margin and my >= h - self.margin:
            self.resize_direction = 'bottom_right'
        elif mx <= self.margin:
            self.resize_direction = 'left'
        elif mx >= w - self.margin:
            self.resize_direction = 'right'
        elif my <= self.margin:
            self.resize_direction = 'top'
        elif my >= h - self.margin:
            self.resize_direction = 'bottom'
        else:
            self.resize_direction = None

    def perform_resize(self, event):
        if not self.resize_direction:
            return

        delta = event.globalPos() - self.resize_start_pos
        geom = self.resize_start_geometry

        if self.resize_direction == 'top_left':
            new_geom = QtCore.QRect(geom.left() + delta.x(), geom.top() + delta.y(), geom.width() - delta.x(), geom.height() - delta.y())
        elif self.resize_direction == 'top_right':
            new_geom = QtCore.QRect(geom.left(), geom.top() + delta.y(), geom.width() + delta.x(), geom.height() - delta.y())
        elif self.resize_direction == 'bottom_left':
            new_geom = QtCore.QRect(geom.left() + delta.x(), geom.top(), geom.width() - delta.x(), geom.height() + delta.y())
        elif self.resize_direction == 'bottom_right':
            new_geom = QtCore.QRect(geom.left(), geom.top(), geom.width() + delta.x(), geom.height() + delta.y())
        elif self.resize_direction == 'left':
            new_geom = QtCore.QRect(geom.left() + delta.x(), geom.top(), geom.width() - delta.x(), geom.height())
        elif self.resize_direction == 'right':
            new_geom = QtCore.QRect(geom.left(), geom.top(), geom.width() + delta.x(), geom.height())
        elif self.resize_direction == 'top':
            new_geom = QtCore.QRect(geom.left(), geom.top() + delta.y(), geom.width(), geom.height() - delta.y())
        elif self.resize_direction == 'bottom':
            new_geom = QtCore.QRect(geom.left(), geom.top(), geom.width(), geom.height() + delta.y())

        if new_geom.width() >= self.margin * 2 and new_geom.height() >= self.margin * 2:
            self.setGeometry(new_geom)

    def update_cursor_shape(self, event):
        rect = self.rect()
        x, y, w, h = rect.x(), rect.y(), rect.width(), rect.height()
        mx, my = event.x(), event.y()

        if mx <= self.margin and my <= self.margin:
            self.setCursor(QtCore.Qt.SizeFDiagCursor)
        elif mx >= w - self.margin and my <= self.margin:
            self.setCursor(QtCore.Qt.SizeBDiagCursor)
        elif mx <= self.margin and my >= h - self.margin:
            self.setCursor(QtCore.Qt.SizeBDiagCursor)
        elif mx >= w - self.margin and my >= h - self.margin:
            self.setCursor(QtCore.Qt.SizeFDiagCursor)
        elif mx <= self.margin:
            self.setCursor(QtCore.Qt.SizeHorCursor)
        elif mx >= w - self.margin:
            self.setCursor(QtCore.Qt.SizeHorCursor)
        elif my <= self.margin:
            self.setCursor(QtCore.Qt.SizeVerCursor)
        elif my >= h - self.margin:
            self.setCursor(QtCore.Qt.SizeVerCursor)
        else:
            self.setCursor(QtCore.Qt.ArrowCursor)

    def paintEvent(self, event):
        painter = QtGui.QPainter(self)
        painter.setBrush(QtGui.QBrush(QtGui.QColor(0, 0, 0)))
        painter.drawRect(self.rect())

class RectangleApp(QtWidgets.QApplication):
    def __init__(self, argv):
        super().__init__(argv)
        self.rectangles = []

    def add_rectangle(self):
        rect = ResizableRectangle()
        rect.show()
        self.rectangles.append(rect)

def main():
    app = RectangleApp(sys.argv)
    app.add_rectangle()
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()
