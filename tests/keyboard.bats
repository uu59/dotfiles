@test "capslock as ctrl" {
  # to fix: https://wiki.archlinux.org/index.php/Keyboard_Configuration_in_Xorg_(%E6%97%A5%E6%9C%AC%E8%AA%9E)#localectl_.E3.82.92.E4.BD.BF.E3.81.86
  # firefoxでCapsLockがCtrlになってくれないのでxmodmapにする http://d.hatena.ne.jp/khiker/20080613/control_caps
  # run localectl list-x11-keymap-options
  # grep -q -F "ctrl:nocaps" <(echo $output)
  run xmodmap -pke
  grep -q -F 'Control_L' <(echo $output | grep -w 66)
}
