# TA4 Addons

Aktuell sind folgende Erweiterungen für TA4 verfügbar:
 - Touchscreen

## Touchscreen

[ta4_addons_touchscreen|image]

Der Touchscreen kann wie ein normales TA 4 Display verwendet werden.
Zusätzlich werden folgende Befehle unterstützt, die es erlauben, ein Formular zu erstellen, das mittels Rechtsklick geöffnet werden kann:

- add_content: Versucht, dem Touchscreen-Formular ein Element hinzuzufügen. Akzeptiert eine Element-Definition als Payload. Gibt im Erfolgsfall die ID des neu erstellten Elements zurück.
- update_content: Versucht, ein bereits bestehendes Element zu modifizieren. Akzeptiert eine Element-Definition mit einem zusätzlichem ID-Feld als Payload. Dieses ID-Feld wird verwendet, um das zu aktualisierende Element zu wählen. Gibt im Erfolgsfall true zurück.
- remove_content: Versucht, ein existierendes Element vom Touchscreen-Formular zu entfernen. Akzeptiert eine Store-Datenstruktur mit einem Feld "id" als Payload. Gibt im Erfolgsfall "true" zurück.
- private: Macht den Touchscreen privat. Nur Spieler mit Störschutz-Zugang können das Formular absenden.
- public: Macht den Touchscreen öffentlich. Alle Spieler können das Formular absenden.

Eine Element-Definition ist eine "Store"-Datenstruktur. Der Element-Typ kann im "type"-Feld dieser Datenstruktur gesetzt werden.
Die Eigenschaften des entsprechenden Elements können als weitere Felder in der Store-Datenstruktur gesetzt werden.
Mehr oder weniger sinnvolle Standardwerte sind grundsätzlich für alle Eigenschaften gesetzt,
es wird aber dringend empfohlen, immer selbst die gewünschten Werte explizit zu übergeben, da die Standardwerte undokumentiert sind und sich ändern können.

Wenn das Formular abgesendet wird, wird eine Store-Struktur an den Controller als Nachricht zurückgesandt.
Diese Datenstruktur beinhaltet alle Felder, die im on_receive_fields callback von Minetest verfügbar sind.
Mittels der Lua-Controller-Funktion $get_msg(true) kann auf diese Store-Struktur zugegriffen werden.
Der Wert "true" für den ersten Parameter darf dabei nicht vergessen werden; ansonsten wird nur die String-Repräsentation der Nachricht zurückgegeben.

Das Formular wird mit der Formspec Version 3 angezeigt (real coordinates aktiviert). Es wird also dringend empfohlen, eine aktuelle Minetest Client-Version zu verwenden.

### Unterstützte Elemente und ihre Eigenschaften

[ta4_addons_touchscreen|image]

Bitte beachte: Diese Liste ist Gegenstand fortwährender Veränderung.

button: x, y, w, h, name, label
label: x, y, label
image: x, y, w, h, texture_name
animated_image: x, y, w, h, name, texture_name, frame_count, frame_duration, frame_start
item_image: x, y, w, h, item_name
pwdfield: x, y, w, h, name, label
field: x, y, w, h, name, label, default
field_close_on_enter: name, close_on_enter
textarea: x, y, w, h, name, label, default
image_button: x, y, w, h, texture_name, name, label
item_image_button: x, y, w, h, item_name, name, label
button_exit: x, y, w, h, name, label
image_button_exit: x, y, w, h, texture_name, name, label
box: x, y, w, h, color
checkbox: x, y, name, label, selected

Für weitere Informationen über die Bedeutung dieser Elemente sei die Datei lua_api.txt des Minetest-Projekts empfohlen.