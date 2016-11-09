require 'irb/completion'
require 'irb/ext/save-history'
require "pathname"

IRB.conf[:SAVE_HISTORY] = 10000
IRB.conf[:HISTORY_FILE] = Pathname.new(__FILE__).parent.join(".irb_history").to_s
