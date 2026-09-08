import sys
import serial.tools.list_ports
from PySide6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, 
    QPushButton, QLabel, QComboBox, QGroupBox, QRadioButton, 
    QStackedWidget, QGridLayout, QDoubleSpinBox
)
from PySide6.QtCore import Qt
from PySide6.QtGui import QFont

from generated_uart_commands import UARTCommands

# ==========================================
# Main GUI Class
# ==========================================
class ATERackGUI(QMainWindow):
    def __init__(self):
        super().__init__()
        
        # Initialize Backend Instance (No serial port yet)
        self.uart = UARTCommands(ser=None)
        
        self.setWindowTitle("ATE Rack Controller")
        self.resize(850, 650)
        self.initUI()
        self.refresh_com_ports()

    def initUI(self):
        # Central Widget
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        main_layout = QVBoxLayout(central_widget)
        main_layout.setSpacing(15)

        # --- Top Bar: COM Port Settings ---
        com_group = QGroupBox("Connection Settings")
        com_layout = QHBoxLayout()
        
        self.combo_ports = QComboBox()
        self.combo_ports.setMinimumWidth(150)
        
        btn_refresh = QPushButton("Refresh Ports")
        btn_refresh.clicked.connect(self.refresh_com_ports)
        
        self.btn_connect = QPushButton("Connect")
        self.btn_connect.setCheckable(True)
        self.btn_connect.toggled.connect(self.toggle_connection)
        
        com_layout.addWidget(QLabel("COM Port:"))
        com_layout.addWidget(self.combo_ports)
        com_layout.addWidget(btn_refresh)
        com_layout.addWidget(self.btn_connect)
        com_layout.addStretch()
        com_group.setLayout(com_layout)
        main_layout.addWidget(com_group)

        # --- ATE General Controls ---
        ate_group = QGroupBox("ATE General Controls")
        ate_layout = QHBoxLayout()
        
        # Toggle Button for Rack Power
        self.btn_power = QPushButton("Turn ON RACK")
        self.btn_power.setMinimumHeight(40)
        self.btn_power.setCheckable(True)
        self.btn_power.toggled.connect(self.toggle_rack_power)
        
        btn_loom = QPushButton("LOOM Test")
        btn_loom.setMinimumHeight(40)
        btn_loom.clicked.connect(lambda: self.uart.Loom(Start_Loom=1))
        
        btn_led = QPushButton("LED Test")
        btn_led.setMinimumHeight(40)
        btn_led.clicked.connect(lambda: self.uart.LED(Start_LED=1))
        
        ate_layout.addWidget(self.btn_power)
        ate_layout.addWidget(btn_loom)
        ate_layout.addWidget(btn_led)
        ate_group.setLayout(ate_layout)
        main_layout.addWidget(ate_group)

        # --- BAND Controls (SFA Modules) ---
        band_group = QGroupBox("BAND Controls (SFA Modules)")
        band_layout = QVBoxLayout()
        
        # Module Selection
        mod_sel_layout = QHBoxLayout()
        self.radio_tarang = QRadioButton("Tarang Module")
        self.radio_r118 = QRadioButton("R118 Module")
        self.radio_tarang.setChecked(True)
        
        self.radio_tarang.toggled.connect(self.switch_sfa_module)
        self.radio_r118.toggled.connect(self.switch_sfa_module)
        
        mod_sel_layout.addWidget(QLabel("Select Active Module:"))
        mod_sel_layout.addWidget(self.radio_tarang)
        mod_sel_layout.addWidget(self.radio_r118)
        mod_sel_layout.addStretch()
        band_layout.addLayout(mod_sel_layout)

        # Stacked Widget for specific module parameters
        self.sfa_stack = QStackedWidget()
        
        # 1. Tarang Widget
        tarang_widget = QWidget()
        tarang_layout = QGridLayout(tarang_widget)
        
        self.tarang_port = QComboBox()
        self.tarang_port.addItems(["Antenna", "BITE"])
        
        self.tarang_mode = QComboBox()
        self.tarang_mode.addItems(["CW", "Pulse"])
        self.tarang_mode.currentTextChanged.connect(self.toggle_pulse_params)
        
        self.tarang_band = QComboBox()
        self.tarang_band.addItems(["BAND 1", "BAND 2", "BAND 3", "BAND 4"])
        
        tarang_layout.addWidget(QLabel("Port:"), 0, 0)
        tarang_layout.addWidget(self.tarang_port, 0, 1)
        tarang_layout.addWidget(QLabel("Mode:"), 0, 2)
        tarang_layout.addWidget(self.tarang_mode, 0, 3)
        tarang_layout.addWidget(QLabel("Band:"), 0, 4)
        tarang_layout.addWidget(self.tarang_band, 0, 5)

        # Tarang Pulse Parameters
        self.pulse_widget = QWidget()
        pulse_layout = QHBoxLayout(self.pulse_widget)
        pulse_layout.setContentsMargins(0, 10, 0, 0)
        
        self.spin_pw = QDoubleSpinBox()
        self.spin_pw.setRange(0.01, 65535.0) # Matches 16-bit max value
        self.spin_pw.setValue(10.0)
        self.spin_pw.setDecimals(2)
        
        self.spin_pri = QDoubleSpinBox()
        self.spin_pri.setRange(0.01, 65535.0)
        self.spin_pri.setValue(100.0)
        self.spin_pri.setDecimals(2)
        
        self.spin_dc = QDoubleSpinBox()
        self.spin_dc.setRange(0.0, 100.0)
        self.spin_dc.setValue(10.0)
        self.spin_dc.setDecimals(2)

        self.spin_pw.editingFinished.connect(self.calc_dc_from_pw_pri)
        self.spin_pri.editingFinished.connect(self.calc_dc_from_pw_pri)
        self.spin_dc.editingFinished.connect(self.calc_pw_from_dc)
        
        pulse_layout.addWidget(QLabel("PW (µs):"))
        pulse_layout.addWidget(self.spin_pw)
        pulse_layout.addWidget(QLabel("PRI (µs):"))
        pulse_layout.addWidget(self.spin_pri)
        pulse_layout.addWidget(QLabel("Duty Cycle (%):"))
        pulse_layout.addWidget(self.spin_dc)
        
        tarang_layout.addWidget(self.pulse_widget, 1, 0, 1, 6)
        self.pulse_widget.setVisible(False)
        self.sfa_stack.addWidget(tarang_widget)

        # 2. R118 Widget
        r118_widget = QWidget()
        r118_layout = QGridLayout(r118_widget)
        
        self.r118_mode = QComboBox()
        self.r118_mode.addItems(["BIT mode RF", "ANT mode RF", "Receiver Termination 50Ohm", "Unused"])
        
        self.r118_band = QComboBox()
        self.r118_band.addItems(["1 - 2 GHz", "2 - 6 GHz", "6 - 10 GHz", "10 - 14 GHz", "14 - 18 GHz"])
        
        r118_layout.addWidget(QLabel("Mode:"), 0, 0)
        r118_layout.addWidget(self.r118_mode, 0, 1)
        r118_layout.addWidget(QLabel("Band:"), 0, 2)
        r118_layout.addWidget(self.r118_band, 0, 3)
        self.sfa_stack.addWidget(r118_widget)

        band_layout.addWidget(self.sfa_stack)

        # Unified Send Button
        self.btn_send_band = QPushButton("Send Tarang Command")
        self.btn_send_band.setMinimumHeight(35)
        self.btn_send_band.clicked.connect(self.send_band_command)
        band_layout.addWidget(self.btn_send_band)
        
        band_group.setLayout(band_layout)
        main_layout.addWidget(band_group)

        # --- Switch Matrix ---
        switch_group = QGroupBox("Switch Matrix Configuration")
        switch_layout = QGridLayout()
        
        self.combo_rf_in = QComboBox()
        self.combo_rf_in.addItems(["Termination","SIG_GEN"])
        switch_layout.addWidget(QLabel("RF_IN to:"), 0, 0)
        switch_layout.addWidget(self.combo_rf_in, 0, 1)

        self.combo_bite_in = QComboBox()
        self.combo_bite_in.addItems(["Termination","SIG_GEN", "Spectrum Analyser"])
        switch_layout.addWidget(QLabel("BITE_IN to:"), 0, 2)
        switch_layout.addWidget(self.combo_bite_in, 0, 3)

        self.combo_rf_out = QComboBox()
        self.combo_rf_out.addItems(["Termination","Spectrum Analyser", "Power meter"])
        switch_layout.addWidget(QLabel("RF_OUT to:"), 1, 0)
        switch_layout.addWidget(self.combo_rf_out, 1, 1)

        btn_apply_switches = QPushButton("Apply Switch Matrix Paths")
        btn_apply_switches.setMinimumHeight(35)
        btn_apply_switches.clicked.connect(self.send_switch_matrix)
        switch_layout.addWidget(btn_apply_switches, 1, 2, 1, 2)

        switch_group.setLayout(switch_layout)
        main_layout.addWidget(switch_group)

        # --- Status Bar ---
        self.statusBar().showMessage("Ready | Disconnected")
        self.apply_styles()

    def apply_styles(self):
        self.setStyleSheet("""
            QMainWindow { background-color: #f0f2f5; }
            QGroupBox {
                font-weight: bold;
                border: 1px solid #c0c4cc;
                border-radius: 5px;
                margin-top: 15px;
                padding-top: 15px;
                color: #2c3e50;
            }
            QGroupBox::title {
                subcontrol-origin: margin;
                left: 10px;
                padding: 0 5px;
                color: #2c3e50;
            }
            QPushButton {
                background-color: #3498db;
                color: white;
                border-radius: 4px;
                padding: 6px;
                font-weight: bold;
            }
            QPushButton:hover { background-color: #2980b9; }
            QPushButton:pressed { background-color: #1c6ea4; }
            QPushButton:checked { background-color: #27ae60; }
            QLabel { color: #2c3e50; }
            QRadioButton { color: #2c3e50; }
            QComboBox, QDoubleSpinBox {
                padding: 4px;
                border: 1px solid #bdc3c7;
                border-radius: 3px;
                background-color: white;
                color: black; 
            }
            QComboBox QAbstractItemView {
                background-color: white;
                color: black; 
                selection-background-color: #3498db;
            }
        """)

    # --- Math & Logic Handlers ---

    def calc_dc_from_pw_pri(self):
        pw = self.spin_pw.value()
        pri = self.spin_pri.value()
        if pri > 0:
            dc = (pw / pri) * 100.0
            if dc > 100.0: dc = 100.0
            self.spin_dc.blockSignals(True)
            self.spin_dc.setValue(dc)
            self.spin_dc.blockSignals(False)

    def calc_pw_from_dc(self):
        dc = self.spin_dc.value()
        pri = self.spin_pri.value()
        pw = (dc / 100.0) * pri
        self.spin_pw.blockSignals(True)
        self.spin_pw.setValue(pw)
        self.spin_pw.blockSignals(False)

    def toggle_pulse_params(self, mode_text):
        self.pulse_widget.setVisible(mode_text == "Pulse")

    # --- UART Handlers Linked to GUI ---

    def toggle_rack_power(self, checked):
        if checked:
            self.btn_power.setText("Turn OFF RACK")
            self.btn_power.setStyleSheet("background-color: #e74c3c;") # Red when ON
            self.uart.TurnONOFF(ON=1, OFF=0)
        else:
            self.btn_power.setText("Turn ON RACK")
            self.btn_power.setStyleSheet("") # Default blue when OFF
            self.uart.TurnONOFF(ON=0, OFF=1)

    def refresh_com_ports(self):
        self.combo_ports.clear()
        ports = serial.tools.list_ports.comports()
        for port in ports:
            self.combo_ports.addItem(port.device)
        if not ports:
            self.combo_ports.addItem("No COM ports found")

    def toggle_connection(self, checked):
        if checked:
            port = self.combo_ports.currentText()
            try:
                # IMPORTANT: Adjust baudrate here if needed
                self.uart.ser = serial.Serial(port, baudrate=115200, timeout=1) 
                
                self.btn_connect.setText("Disconnect")
                self.btn_connect.setStyleSheet("background-color: #e74c3c;")
                self.statusBar().showMessage(f"Connected to {port}")
            except Exception as e:
                self.statusBar().showMessage(f"Failed to connect: {e}")
                self.btn_connect.setChecked(False) # Reset button
        else:
            if self.uart.ser and self.uart.ser.is_open:
                self.uart.ser.close()
            self.uart.ser = None
            self.btn_connect.setText("Connect")
            self.btn_connect.setStyleSheet("")
            self.statusBar().showMessage("Ready | Disconnected")

    def switch_sfa_module(self):
        if self.radio_tarang.isChecked():
            self.sfa_stack.setCurrentIndex(0)
            self.btn_send_band.setText("Send Tarang Command")
        else:
            self.sfa_stack.setCurrentIndex(1)
            self.btn_send_band.setText("Send R118 Command")

    def send_band_command(self):
        if self.radio_tarang.isChecked():
            port_idx = self.tarang_port.currentIndex()
            mode_idx = self.tarang_mode.currentIndex()
            band_idx = self.tarang_band.currentIndex()
            
            pw_int = 0
            pri_int = 0
            
            if self.tarang_mode.currentText() == "Pulse":
                # Multiply by 1000 for ns, round to nearest whole number, cast to int
                pw_int = int(round(self.spin_pw.value() * 1000))
                pri_int = int(round(self.spin_pri.value() * 1000))
            
            self.uart.Tarang(
                Tarang_BAND=band_idx, 
                Tarang_MODE=mode_idx, 
                Tarang_PORT=port_idx, 
                Pulse_width=pw_int, 
                PRI=pri_int
            )
        else:
            mode_idx = self.r118_mode.currentIndex()
            band_idx = self.r118_band.currentIndex()
            self.uart.R118(R118_BAND=band_idx, R118_MODE=mode_idx)

    def send_switch_matrix(self):
        rf_in_idx = self.combo_rf_in.currentIndex()
        bite_in_idx = self.combo_bite_in.currentIndex()
        rf_out_idx = self.combo_rf_out.currentIndex()
        
        self.uart.Switch_matrix(
            RF_IN=rf_in_idx, 
            RF_OUT=rf_out_idx, 
            BITE_IN=bite_in_idx
        )

if __name__ == "__main__":
    app = QApplication(sys.line_arguments() if hasattr(sys, 'line_arguments') else sys.argv)
    app.setFont(QFont("Segoe UI", 10))
    window = ATERackGUI()
    window.show()
    sys.exit(app.exec())