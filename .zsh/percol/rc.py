# https://gist.github.com/mitukiii/4234173

import sys, commands
from percol.command import SelectorCommand
from percol.key import SPECIAL_KEYS
from percol.finder import FinderMultiQueryMigemo, FinderMultiQueryRegex

## prompt
# Case Insensitive / Match Method に応じてプロンプトに表示
def dynamic_prompt():
    prompt = ur""
    if percol.model.finder.__class__ == FinderMultiQueryMigemo:
        prompt += "[Migemo]"
    elif percol.model.finder.__class__ == FinderMultiQueryRegex:
        prompt += "[Regexp]"
    else:
        prompt += "[String]"
    if percol.model.finder.case_insensitive:
        prompt += "[a]"
    else:
        prompt += "[A]"
    prompt += "> %q"
    return prompt

percol.view.__class__.PROMPT = property(lambda self: dynamic_prompt())

## migemo
# Mac と Ubuntu で辞書のパスを変える
if sys.platform == "darwin":
    FinderMultiQueryMigemo.dictionary_path = "/usr/local/Cellar/cmigemo/20110227/share/migemo/utf-8/migemo-dict"
else:
    FinderMultiQueryMigemo.dictionary_path = "/usr/share/cmigemo/utf-8/migemo-dict"


## keymap
# Mac で delete（backspace）が効くようにする
SPECIAL_KEYS.update({
    127: '<backspace>'
})
percol.import_keymap({
    "C-a" : lambda percol: percol.command.beginning_of_line(),
    "C-e" : lambda percol: percol.command.end_of_line(),
    "C-b" : lambda percol: percol.command.backward_char(),
    "C-f" : lambda percol: percol.command.forward_char(),
    "C-d" : lambda percol: percol.command.delete_forward_char(),
    "C-h" : lambda percol: percol.command.delete_backward_char(),
    "C-k" : lambda percol: percol.command.kill_end_of_line(),
    "C-y" : lambda percol: percol.command.yank(),
    "C-n" : lambda percol: percol.command.select_next(),
    "C-p" : lambda percol: percol.command.select_previous(),
    "C-v" : lambda percol: percol.command.select_next_page(),
    "C-m" : lambda percol: percol.finish(),
    "M-m" : lambda percol: percol.command.toggle_finder(FinderMultiQueryMigemo),
    "M-r" : lambda percol: percol.command.toggle_finder(FinderMultiQueryRegex)
})
